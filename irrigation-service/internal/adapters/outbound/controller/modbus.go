package controller

import (
	"context"
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"sync/atomic"
	"time"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// Modbus TCP, written out rather than pulled in.
//
// The wire format is small, frozen and forty years old: a six-byte header, a
// unit id, a function code and two 16-bit words. Writing it here keeps a
// dependency out of a service that opens valves, and — more usefully — means
// the exception path is ours to get right. A Modbus slave reports a refusal by
// setting the top bit of the function code and returning a one-byte reason,
// and that refusal is information from the panel, not a transport failure.

const (
	modbusWriteSingleCoil     byte = 0x05
	modbusWriteSingleRegister byte = 0x06
	modbusReadCoils           byte = 0x01
	modbusExceptionFlag       byte = 0x80

	// modbusCoilOn is the only value a write-single-coil accepts for "on";
	// 0x0000 is off and everything else is an illegal data value.
	modbusCoilOn  uint16 = 0xFF00
	modbusCoilOff uint16 = 0x0000

	modbusHeaderLen   = 7 // transaction, protocol, length, unit
	modbusDefaultPort = "502"
)

// modbusClient writes coils on irrigation panels and pump controllers.
type modbusClient struct {
	dial    func(ctx context.Context, address string) (net.Conn, error)
	timeout time.Duration
	// txn is the Modbus transaction identifier, echoed by the slave so a reply
	// can be matched to its request. Monotonic per process rather than per
	// connection because each command opens its own connection: overlapping
	// transactions on one socket are what the field is for, and we never have
	// them.
	txn atomic.Uint32
}

// NewModbusClient creates a Modbus TCP client.
//
// The endpoint is the panel: `host:port?unit=1&coil=3&duration_register=100`.
// Port defaults to 502, unit to 1, coil to 0. A duration register is optional
// — panels that enforce their own run time expose one, and those that do not
// rely on the STOP that follows.
func NewModbusClient(timeout time.Duration) outbound.ControllerClient {
	if timeout <= 0 {
		timeout = DefaultTimeout
	}
	return &modbusClient{
		dial: func(ctx context.Context, address string) (net.Conn, error) {
			var d net.Dialer
			return d.DialContext(ctx, "tcp", address)
		},
		timeout: timeout,
	}
}

// Send writes the command to the panel.
//
// A START writes the duration first and the coil second, and the order is the
// safety property: a panel that takes the coil before it has the duration runs
// on whatever value was left in that register from last time. If the duration
// write fails the coil is never written, so the valve stays shut.
//
// Modbus has no idempotency key, and needs none here: writing a coil that is
// already on is the same state, not a second run. That is why the actuator's
// already_running interlock exists upstream of it.
func (m *modbusClient) Send(
	ctx context.Context,
	c *domain.WaterController,
	cmd *domain.IrrigationCommand,
) (*outbound.ControllerAck, error) {
	if c == nil || cmd == nil {
		return nil, fmt.Errorf("modbus: controller and command are required")
	}
	ep, err := parseEndpoint(c.Endpoint)
	if err != nil {
		return nil, fmt.Errorf("modbus: %w", err)
	}
	unit, coil, durationReg, err := modbusOptions(ep)
	if err != nil {
		return nil, fmt.Errorf("modbus: %w", err)
	}

	conn, err := m.dial(ctx, withDefaultPort(ep.target))
	if err != nil {
		return nil, fmt.Errorf("modbus: dial %s: %w", ep.target, err)
	}
	defer conn.Close() //nolint:errcheck

	if deadline, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(deadline)
	} else {
		_ = conn.SetDeadline(time.Now().Add(m.timeout))
	}

	if cmd.Kind == domain.CommandStart && durationReg >= 0 {
		if ack, err := m.write(conn, byte(unit), modbusWriteSingleRegister,
			uint16(durationReg), uint16(cmd.DurationMinutes)); err != nil {
			return nil, fmt.Errorf("modbus: writing the run duration: %w", err)
		} else if !ack.Accepted {
			// Refused before the valve was touched, which is the point of the
			// ordering.
			return ack, nil
		}
	}

	value := modbusCoilOff
	if cmd.Kind == domain.CommandStart {
		value = modbusCoilOn
	}
	return m.write(conn, byte(unit), modbusWriteSingleCoil, uint16(coil), value)
}

// Status reads the coil back.
//
// This is the one transport of the three that can answer the question
// directly: the panel holds the valve's actual position, so a service that
// believes a zone is running can check rather than assume.
func (m *modbusClient) Status(ctx context.Context, c *domain.WaterController) (*outbound.ControllerStatus, error) {
	if c == nil {
		return nil, fmt.Errorf("modbus: controller is required")
	}
	ep, err := parseEndpoint(c.Endpoint)
	if err != nil {
		return nil, fmt.Errorf("modbus: %w", err)
	}
	unit, coil, _, err := modbusOptions(ep)
	if err != nil {
		return nil, fmt.Errorf("modbus: %w", err)
	}

	conn, err := m.dial(ctx, withDefaultPort(ep.target))
	if err != nil {
		// Unreachable is a status, not a failure to report: a panel that does
		// not answer is exactly what the caller wants to know.
		return &outbound.ControllerStatus{Online: false, Fault: err.Error()}, nil
	}
	defer conn.Close() //nolint:errcheck

	if deadline, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(deadline)
	} else {
		_ = conn.SetDeadline(time.Now().Add(m.timeout))
	}

	resp, err := m.roundTrip(conn, byte(unit), modbusReadCoils, uint16(coil), 1)
	if err != nil {
		return &outbound.ControllerStatus{Online: false, Fault: err.Error()}, nil
	}
	if code, ok := modbusException(resp); ok {
		return &outbound.ControllerStatus{Online: true, Fault: modbusExceptionText(code)}, nil
	}
	// A read-coils reply is [fn][byte count][bits...]; bit 0 of the first
	// data byte is the coil asked for.
	if len(resp) < 3 {
		return &outbound.ControllerStatus{Online: true, Fault: "panel sent a truncated coil reply"}, nil
	}
	return &outbound.ControllerStatus{Online: true, Running: resp[2]&0x01 == 1}, nil
}

// write performs one write function and reads the slave's reply.
//
// A successful write is echoed back verbatim, so the echo is checked rather
// than assumed: a panel that answers with a different address or value did
// something other than what was asked, and treating that as success would
// report a valve open that is not.
func (m *modbusClient) write(conn net.Conn, unit, fn byte, address, value uint16) (*outbound.ControllerAck, error) {
	resp, err := m.roundTrip(conn, unit, fn, address, value)
	if err != nil {
		return nil, err
	}
	if code, ok := modbusException(resp); ok {
		// The panel answered and said no. That is information — a local
		// lockout, a low reservoir, an interlock of its own — not a fault.
		return &outbound.ControllerAck{Accepted: false, Reason: modbusExceptionText(code)}, nil
	}
	if len(resp) < 5 {
		return nil, fmt.Errorf("panel sent a %d-byte reply to a write", len(resp))
	}
	gotAddr := binary.BigEndian.Uint16(resp[1:3])
	gotValue := binary.BigEndian.Uint16(resp[3:5])
	if resp[0] != fn || gotAddr != address || gotValue != value {
		return nil, fmt.Errorf(
			"panel echoed fn=%#x addr=%d value=%#x for a write of fn=%#x addr=%d value=%#x",
			resp[0], gotAddr, gotValue, fn, address, value)
	}
	return &outbound.ControllerAck{Accepted: true}, nil
}

// roundTrip sends one MBAP frame and returns the reply's PDU.
func (m *modbusClient) roundTrip(conn net.Conn, unit, fn byte, address, value uint16) ([]byte, error) {
	txn := uint16(m.txn.Add(1))
	if _, err := conn.Write(modbusFrame(txn, unit, fn, address, value)); err != nil {
		return nil, fmt.Errorf("write: %w", err)
	}

	header := make([]byte, modbusHeaderLen)
	if _, err := io.ReadFull(conn, header); err != nil {
		return nil, fmt.Errorf("read header: %w", err)
	}
	if got := binary.BigEndian.Uint16(header[0:2]); got != txn {
		return nil, fmt.Errorf("panel replied to transaction %d while waiting for %d", got, txn)
	}
	// Length counts the unit id plus the PDU, and the unit id is already in
	// the header we read.
	length := int(binary.BigEndian.Uint16(header[4:6]))
	if length < 2 || length > 256 {
		return nil, fmt.Errorf("panel declared a %d-byte reply", length)
	}
	pdu := make([]byte, length-1)
	if _, err := io.ReadFull(conn, pdu); err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}
	return pdu, nil
}

// modbusFrame builds an MBAP header plus a four-byte PDU.
func modbusFrame(txn uint16, unit, fn byte, address, value uint16) []byte {
	frame := make([]byte, 12)
	binary.BigEndian.PutUint16(frame[0:2], txn)
	binary.BigEndian.PutUint16(frame[2:4], 0) // protocol id: always 0 for Modbus
	binary.BigEndian.PutUint16(frame[4:6], 6) // unit id + 5-byte PDU
	frame[6] = unit
	frame[7] = fn
	binary.BigEndian.PutUint16(frame[8:10], address)
	binary.BigEndian.PutUint16(frame[10:12], value)
	return frame
}

// modbusException reports whether a PDU is an exception reply and its code.
func modbusException(pdu []byte) (byte, bool) {
	if len(pdu) >= 2 && pdu[0]&modbusExceptionFlag != 0 {
		return pdu[1], true
	}
	return 0, false
}

// modbusExceptionText names a refusal, because "exception 6" in a log during a
// callout tells an operator nothing.
func modbusExceptionText(code byte) string {
	switch code {
	case 0x01:
		return "the panel does not support this function"
	case 0x02:
		return "the panel has no such coil or register at that address"
	case 0x03:
		return "the panel rejected the value as out of range"
	case 0x04:
		return "the panel reported a failure carrying out the command"
	case 0x05:
		return "the panel accepted the request but needs longer to act on it"
	case 0x06:
		return "the panel is busy with another command"
	case 0x0B:
		return "the gateway got no response from the panel"
	default:
		return fmt.Sprintf("the panel refused the command (modbus exception %#x)", code)
	}
}

// modbusOptions reads the unit, coil and optional duration register.
//
// durationReg is -1 when the panel has none, which is distinct from register
// zero — a real and commonly used address.
func modbusOptions(ep endpoint) (unit, coil, durationReg int, err error) {
	if unit, err = ep.intOpt("unit", 1); err != nil {
		return 0, 0, 0, err
	}
	if coil, err = ep.intOpt("coil", 0); err != nil {
		return 0, 0, 0, err
	}
	durationReg = -1
	if raw := ep.opts.Get("duration_register"); raw != "" {
		if durationReg, err = ep.intOpt("duration_register", -1); err != nil {
			return 0, 0, 0, err
		}
	}
	if unit < 0 || unit > 255 {
		return 0, 0, 0, fmt.Errorf("unit id %d is outside 0..255", unit)
	}
	if coil < 0 || coil > 0xFFFF {
		return 0, 0, 0, fmt.Errorf("coil address %d is outside 0..65535", coil)
	}
	return unit, coil, durationReg, nil
}

// withDefaultPort appends Modbus's registered port when the endpoint omits it.
func withDefaultPort(target string) string {
	if _, _, err := net.SplitHostPort(target); err == nil {
		return target
	}
	return net.JoinHostPort(target, modbusDefaultPort)
}
