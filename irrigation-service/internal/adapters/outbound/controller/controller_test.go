package controller

import (
	"context"
	"encoding/base64"
	"encoding/binary"
	"encoding/json"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"p9e.in/samavaya/agriculture/irrigation-service/internal/domain"
	"p9e.in/samavaya/agriculture/irrigation-service/internal/ports/outbound"
)

// What these are for: every one of these transports offers something that
// looks like an acknowledgement and is not the valve moving. The tests that
// matter are the ones pinning what each client reports when it has not
// actually been told anything by the controller.

func startCommand() *domain.IrrigationCommand {
	return &domain.IrrigationCommand{
		ID: "01JBQZK8P0ABCDEFGHJKMNPQRS", TenantID: "t-1", ZoneID: "z-1",
		Kind: domain.CommandStart, DurationMinutes: 30,
		IssuedBy: "user-1", Reason: "operator", IssuedAt: time.Now(),
	}
}

// ---------------------------------------------------------------------------
// Registry

// A protocol with no client is refused by name, not served by whichever client
// happens to exist. A farm reached over LoRaWAN whose command quietly went out
// over MQTT would be a valve nobody could account for.
func TestAnUnconfiguredProtocolIsRefusedByName(t *testing.T) {
	r := NewRegistry(map[domain.Protocol]outbound.ControllerClient{
		domain.ProtocolModbus: NewModbusClient(time.Second),
	})

	_, err := r.Send(context.Background(),
		&domain.WaterController{Protocol: domain.ProtocolLoRaWAN}, startCommand())
	if err == nil {
		t.Fatal("a LoRaWAN command was accepted by a Modbus-only registry")
	}
	if !strings.Contains(err.Error(), "LORAWAN") {
		t.Errorf("error %q does not name the protocol", err)
	}
}

// An empty registry is a deployment with no hardware, and refuses everything.
func TestAnEmptyRegistryRefusesEverything(t *testing.T) {
	if _, err := NewRegistry(nil).Send(context.Background(),
		&domain.WaterController{Protocol: domain.ProtocolMQTT}, startCommand()); err == nil {
		t.Fatal("an empty registry accepted a command")
	}
}

// ---------------------------------------------------------------------------
// Endpoint parsing

func TestEndpointParsing(t *testing.T) {
	if _, err := parseEndpoint("  "); err == nil {
		t.Error("an empty endpoint was accepted; there is nowhere to send the command")
	}

	ep, err := parseEndpoint("10.0.0.5:502?unit=3&coil=7")
	if err != nil {
		t.Fatalf("parseEndpoint: %v", err)
	}
	if ep.target != "10.0.0.5:502" {
		t.Errorf("target = %q", ep.target)
	}
	unit, coil, durationReg, err := modbusOptions(ep)
	if err != nil {
		t.Fatalf("modbusOptions: %v", err)
	}
	if unit != 3 || coil != 7 {
		t.Errorf("unit/coil = %d/%d, want 3/7", unit, coil)
	}
	// -1, not 0: register zero is a real and commonly used address, so "no
	// duration register" has to be distinguishable from "register 0".
	if durationReg != -1 {
		t.Errorf("durationReg = %d, want -1 when none is configured", durationReg)
	}
}

// ---------------------------------------------------------------------------
// Modbus

// fakePanel answers Modbus frames with a scripted reply per function code.
func fakePanel(t *testing.T, reply func(fn byte, addr, value uint16) []byte) string {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("listen: %v", err)
	}
	t.Cleanup(func() { ln.Close() }) //nolint:errcheck

	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			go func() {
				defer conn.Close() //nolint:errcheck
				for {
					frame := make([]byte, 12)
					if _, err := io.ReadFull(conn, frame); err != nil {
						return
					}
					txn := binary.BigEndian.Uint16(frame[0:2])
					unit := frame[6]
					pdu := reply(frame[7],
						binary.BigEndian.Uint16(frame[8:10]),
						binary.BigEndian.Uint16(frame[10:12]))

					out := make([]byte, 0, modbusHeaderLen+len(pdu))
					head := make([]byte, modbusHeaderLen)
					binary.BigEndian.PutUint16(head[0:2], txn)
					binary.BigEndian.PutUint16(head[2:4], 0)
					binary.BigEndian.PutUint16(head[4:6], uint16(len(pdu)+1))
					head[6] = unit
					out = append(out, head...)
					out = append(out, pdu...)
					if _, err := conn.Write(out); err != nil {
						return
					}
				}
			}()
		}
	}()
	return ln.Addr().String()
}

// echo is what a Modbus slave returns for a successful write.
func echo(fn byte, addr, value uint16) []byte {
	pdu := make([]byte, 5)
	pdu[0] = fn
	binary.BigEndian.PutUint16(pdu[1:3], addr)
	binary.BigEndian.PutUint16(pdu[3:5], value)
	return pdu
}

// A start writes the duration before the coil, and the ordering is the safety
// property: a panel that takes the coil before it has the duration runs on
// whatever was left in that register from last time.
func TestModbusWritesTheDurationBeforeTheCoil(t *testing.T) {
	var order []byte
	var wrote = map[byte]uint16{}
	addr := fakePanel(t, func(fn byte, a, v uint16) []byte {
		order = append(order, fn)
		wrote[fn] = v
		return echo(fn, a, v)
	})

	client := NewModbusClient(2 * time.Second)
	ack, err := client.Send(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolModbus,
		Endpoint: addr + "?unit=1&coil=3&duration_register=100",
	}, startCommand())
	if err != nil {
		t.Fatalf("Send: %v", err)
	}
	if !ack.Accepted {
		t.Fatalf("ack = %+v, want accepted", ack)
	}

	if len(order) != 2 || order[0] != modbusWriteSingleRegister || order[1] != modbusWriteSingleCoil {
		t.Fatalf("write order = %#x, want the duration register then the coil", order)
	}
	if wrote[modbusWriteSingleRegister] != 30 {
		t.Errorf("duration register got %d, want 30", wrote[modbusWriteSingleRegister])
	}
	if wrote[modbusWriteSingleCoil] != modbusCoilOn {
		t.Errorf("coil got %#x, want %#x", wrote[modbusWriteSingleCoil], modbusCoilOn)
	}
}

// If the duration write is refused, the coil is never written and the valve
// stays shut.
func TestModbusDoesNotOpenTheValveWhenTheDurationIsRefused(t *testing.T) {
	var functions []byte
	addr := fakePanel(t, func(fn byte, a, v uint16) []byte {
		functions = append(functions, fn)
		if fn == modbusWriteSingleRegister {
			return []byte{fn | modbusExceptionFlag, 0x03} // illegal data value
		}
		return echo(fn, a, v)
	})

	ack, err := NewModbusClient(2*time.Second).Send(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolModbus,
		Endpoint: addr + "?coil=3&duration_register=100",
	}, startCommand())
	if err != nil {
		t.Fatalf("Send: %v", err)
	}
	if ack.Accepted {
		t.Error("the command was accepted although the duration was refused")
	}
	for _, fn := range functions {
		if fn == modbusWriteSingleCoil {
			t.Fatal("the coil was written after the duration was refused")
		}
	}
}

// A stop writes the coil off, and skips the duration entirely.
func TestModbusStopClosesTheCoil(t *testing.T) {
	var value uint16 = 0xDEAD
	addr := fakePanel(t, func(fn byte, a, v uint16) []byte {
		value = v
		return echo(fn, a, v)
	})

	cmd := startCommand()
	cmd.Kind = domain.CommandStop
	cmd.DurationMinutes = 0

	if _, err := NewModbusClient(2*time.Second).Send(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolModbus,
		Endpoint: addr + "?coil=3&duration_register=100",
	}, cmd); err != nil {
		t.Fatalf("Send: %v", err)
	}
	if value != modbusCoilOff {
		t.Errorf("coil got %#x, want %#x", value, modbusCoilOff)
	}
}

// A panel that answers with a different address or value did something other
// than what was asked. Treating that as success would report a valve open that
// is not.
func TestModbusRejectsAMismatchedEcho(t *testing.T) {
	addr := fakePanel(t, func(fn byte, a, v uint16) []byte {
		return echo(fn, a+1, v) // wrong coil
	})

	_, err := NewModbusClient(2*time.Second).Send(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolModbus,
		Endpoint: addr + "?coil=3",
	}, startCommand())
	if err == nil {
		t.Fatal("a mismatched echo was read as a successful write")
	}
}

// A panel refusing is information — a local lockout, a low reservoir — not a
// transport fault, so it comes back as a refusal rather than an error.
func TestModbusExceptionIsARefusalNotAFailure(t *testing.T) {
	addr := fakePanel(t, func(fn byte, _, _ uint16) []byte {
		return []byte{fn | modbusExceptionFlag, 0x06} // slave device busy
	})

	ack, err := NewModbusClient(2*time.Second).Send(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolModbus, Endpoint: addr + "?coil=3",
	}, startCommand())
	if err != nil {
		t.Fatalf("a panel refusal came back as an error: %v", err)
	}
	if ack.Accepted {
		t.Error("a refused command was reported as accepted")
	}
	if !strings.Contains(ack.Reason, "busy") {
		t.Errorf("reason %q does not say what the panel said", ack.Reason)
	}
}

// Status reads the coil back, which is the one thing these three transports
// can do that the other two cannot.
func TestModbusStatusReadsTheValveBack(t *testing.T) {
	addr := fakePanel(t, func(fn byte, _, _ uint16) []byte {
		return []byte{fn, 0x01, 0x01} // one byte of coil data, bit 0 set
	})

	got, err := NewModbusClient(2*time.Second).Status(context.Background(),
		&domain.WaterController{Protocol: domain.ProtocolModbus, Endpoint: addr + "?coil=3"})
	if err != nil {
		t.Fatalf("Status: %v", err)
	}
	if !got.Online || !got.Running {
		t.Errorf("status = %+v, want online and running", got)
	}
}

// An unreachable panel is a status, not an error: the caller asked what the
// controller is doing and "we cannot reach it" is the answer.
func TestModbusUnreachableIsAStatus(t *testing.T) {
	got, err := NewModbusClient(200*time.Millisecond).Status(context.Background(),
		&domain.WaterController{Protocol: domain.ProtocolModbus, Endpoint: "127.0.0.1:1?coil=0"})
	if err != nil {
		t.Fatalf("Status returned an error for an unreachable panel: %v", err)
	}
	if got.Online {
		t.Error("an unreachable panel reported online")
	}
}

func TestModbusDefaultsToTheRegisteredPort(t *testing.T) {
	if got := withDefaultPort("10.0.0.5"); got != "10.0.0.5:502" {
		t.Errorf("withDefaultPort = %q, want 10.0.0.5:502", got)
	}
	if got := withDefaultPort("10.0.0.5:1502"); got != "10.0.0.5:1502" {
		t.Errorf("withDefaultPort overrode an explicit port: %q", got)
	}
}

// ---------------------------------------------------------------------------
// LoRaWAN

// The downlink has to fit. The JSON the other transports carry runs to about
// 140 bytes — two ULIDs and a timestamp — against 51 bytes at SF12, so every
// command to a device at the edge of a field would have been rejected.
func TestALoRaWANCommandFitsTheSlowestDataRate(t *testing.T) {
	packed, err := encodeLoRaWANCommand(startCommand())
	if err != nil {
		t.Fatalf("encodeLoRaWANCommand: %v", err)
	}
	if len(packed) > maxLoRaWANPayload {
		t.Errorf("packed command is %d bytes, over the %d-byte SF12 downlink",
			len(packed), maxLoRaWANPayload)
	}

	// The shape this replaced, for the record.
	asJSON, err := encodeCommand(startCommand())
	if err != nil {
		t.Fatalf("encodeCommand: %v", err)
	}
	if len(asJSON) <= maxLoRaWANPayload {
		t.Skip("the JSON command now fits a downlink; the packed encoding may be unnecessary")
	}
}

func TestALoRaWANCommandCarriesKindAndDuration(t *testing.T) {
	packed, err := encodeLoRaWANCommand(startCommand())
	if err != nil {
		t.Fatalf("encodeLoRaWANCommand: %v", err)
	}
	if packed[0] != loRaWANFormatVersion {
		t.Errorf("version = %d", packed[0])
	}
	if packed[1] != loRaWANKindStart {
		t.Errorf("kind = %d, want start", packed[1])
	}
	if got := binary.BigEndian.Uint16(packed[2:4]); got != 30 {
		t.Errorf("duration = %d, want 30", got)
	}

	stop := startCommand()
	stop.Kind = domain.CommandStop
	packed, err = encodeLoRaWANCommand(stop)
	if err != nil {
		t.Fatalf("encodeLoRaWANCommand: %v", err)
	}
	if packed[1] != loRaWANKindStop {
		t.Errorf("kind = %d, want stop", packed[1])
	}
}

// The idempotency token is deterministic, which is the whole job of the
// command id on a link this lossy: a retry must let the device recognise the
// repeat rather than open the valve a second time.
func TestTheLoRaWANTokenIsStableAcrossRetries(t *testing.T) {
	first, _ := encodeLoRaWANCommand(startCommand())
	second, _ := encodeLoRaWANCommand(startCommand())
	if string(first[4:]) != string(second[4:]) {
		t.Error("the same command produced two different tokens; a retry would open the valve twice")
	}

	other := startCommand()
	other.ID = "01JBQZK8P0ZZZZZZZZZZZZZZZZ"
	third, _ := encodeLoRaWANCommand(other)
	if string(first[4:]) == string(third[4:]) {
		t.Error("two different commands share a token; the second would be ignored as a repeat")
	}
}

// A network server's 200 means queued, and the client says so rather than
// reporting that a valve opened.
func TestLoRaWANReportsQueuedNotAccepted(t *testing.T) {
	var got lorawanQueueRequest
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer tok" {
			t.Errorf("Authorization = %q", r.Header.Get("Authorization"))
		}
		_ = json.NewDecoder(r.Body).Decode(&got)
		w.WriteHeader(http.StatusOK)
	}))
	defer srv.Close()

	client, err := NewLoRaWANClient(LoRaWANConfig{BaseURL: srv.URL, APIToken: "tok", Confirmed: true})
	if err != nil {
		t.Fatalf("NewLoRaWANClient: %v", err)
	}

	ack, err := client.Send(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolLoRaWAN, Endpoint: "0004a30b001c0530?f_port=12",
	}, startCommand())
	if err != nil {
		t.Fatalf("Send: %v", err)
	}
	if !ack.Queued {
		t.Error("Queued = false; the device has not heard anything yet")
	}
	if got.QueueItem.DevEUI != "0004a30b001c0530" {
		t.Errorf("devEui = %q", got.QueueItem.DevEUI)
	}
	if got.QueueItem.FPort != 12 {
		t.Errorf("fPort = %d, want the endpoint's override of 12", got.QueueItem.FPort)
	}
	if !got.QueueItem.Confirmed {
		t.Error("confirmed = false; a command that opens a valve asks for a MAC-layer ack")
	}
	raw, err := base64.StdEncoding.DecodeString(got.QueueItem.Data)
	if err != nil || len(raw) != loRaWANCommandBytes {
		t.Errorf("data decoded to %d bytes (%v)", len(raw), err)
	}
}

// An unknown device is a refusal: retrying will not conjure it.
func TestLoRaWANUnknownDeviceIsARefusal(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNotFound)
	}))
	defer srv.Close()

	client, _ := NewLoRaWANClient(LoRaWANConfig{BaseURL: srv.URL, APIToken: "tok"})
	ack, err := client.Send(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolLoRaWAN, Endpoint: "0004a30b001c0530",
	}, startCommand())
	if err != nil {
		t.Fatalf("an unknown device came back as an error: %v", err)
	}
	if ack.Accepted || ack.Queued {
		t.Errorf("ack = %+v, want a refusal", ack)
	}
}

// A 5xx says nothing about the command, so it is an error and the actuator
// records the send as unknown rather than as a refusal.
func TestLoRaWANServerFaultIsUnknownNotRefused(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusBadGateway)
	}))
	defer srv.Close()

	client, _ := NewLoRaWANClient(LoRaWANConfig{BaseURL: srv.URL, APIToken: "tok"})
	if _, err := client.Send(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolLoRaWAN, Endpoint: "0004a30b001c0530",
	}, startCommand()); err == nil {
		t.Fatal("a 502 was reported as a decided outcome")
	}
}

func TestLoRaWANNeedsATokenToEnqueueDownlinks(t *testing.T) {
	if _, err := NewLoRaWANClient(LoRaWANConfig{BaseURL: "http://ns"}); err == nil {
		t.Error("a client was built with no API token")
	}
}

// ---------------------------------------------------------------------------
// Ack decoding, shared by the packet transports

// Several controllers share a broker and an operator can send two commands to
// one zone within a second. Without the id check the first reply to arrive
// would be read as the answer to whichever command was waiting, and a refusal
// could be recorded as an acceptance.
func TestAnAckForAnotherCommandIsNotAnAnswer(t *testing.T) {
	raw, _ := json.Marshal(ackPayload{CommandID: "someone-else", Accepted: true})
	if _, err := decodeAck(raw, "mine"); err == nil {
		t.Fatal("an ack for a different command was accepted as the answer")
	}

	raw, _ = json.Marshal(ackPayload{CommandID: "mine", Accepted: false, Reason: "low reservoir"})
	ack, err := decodeAck(raw, "mine")
	if err != nil {
		t.Fatalf("decodeAck: %v", err)
	}
	if ack.Accepted || ack.Reason != "low reservoir" {
		t.Errorf("ack = %+v", ack)
	}
}

// ---------------------------------------------------------------------------
// The water meter

// regPanel answers write functions with an echo and register reads from a map.
func regPanel(t *testing.T, regs map[uint16][]byte) string {
	t.Helper()
	return fakePanel(t, func(fn byte, addr, value uint16) []byte {
		if fn != modbusReadHoldingRegs {
			return echo(fn, addr, value)
		}
		data, ok := regs[addr]
		if !ok {
			return []byte{fn | modbusExceptionFlag, 0x02} // illegal data address
		}
		pdu := []byte{fn, byte(len(data))}
		return append(pdu, data...)
	})
}

// A totaliser lives across two registers, high word first.
func TestModbusReadsTheWaterMeter(t *testing.T) {
	// 1,234,567 litres = 0x0012D687
	addr := regPanel(t, map[uint16][]byte{
		200: {0x00, 0x12, 0xD6, 0x87},
	})

	got, err := NewModbusClient(2*time.Second).Status(context.Background(),
		&domain.WaterController{
			Protocol: domain.ProtocolModbus,
			Endpoint: addr + "?coil=3&meter_register=200",
		})
	if err != nil {
		t.Fatalf("Status: %v", err)
	}
	if !got.HasVolumeTotal {
		t.Fatalf("HasVolumeTotal = false; status = %+v", got)
	}
	if got.VolumeTotalLiters != 1234567 {
		t.Errorf("VolumeTotalLiters = %v, want 1234567", got.VolumeTotalLiters)
	}
}

// Meters rarely count in whole litres. One that counts tenths and is read as
// litres reports a run ten times larger than it was.
func TestTheMeterScaleIsApplied(t *testing.T) {
	// 84,000 tenths of a litre = 8,400 L
	addr := regPanel(t, map[uint16][]byte{
		200: {0x00, 0x01, 0x48, 0x20},
	})

	got, err := NewModbusClient(2*time.Second).Status(context.Background(),
		&domain.WaterController{
			Protocol: domain.ProtocolModbus,
			Endpoint: addr + "?coil=3&meter_register=200&meter_scale=0.1",
		})
	if err != nil {
		t.Fatalf("Status: %v", err)
	}
	if got.VolumeTotalLiters != 8400 {
		t.Errorf("VolumeTotalLiters = %v, want 8400", got.VolumeTotalLiters)
	}
}

// A panel with no meter configured reports none, rather than a zero reading.
// A zero totaliser would be a run that used no water.
func TestAPanelWithNoMeterReportsNone(t *testing.T) {
	addr := regPanel(t, nil)

	got, err := NewModbusClient(2*time.Second).Status(context.Background(),
		&domain.WaterController{Protocol: domain.ProtocolModbus, Endpoint: addr + "?coil=3"})
	if err != nil {
		t.Fatalf("Status: %v", err)
	}
	if got.HasVolumeTotal {
		t.Error("a panel with no meter_register reported a volume")
	}
	if got.VolumeTotalLiters != 0 {
		t.Errorf("VolumeTotalLiters = %v with no meter", got.VolumeTotalLiters)
	}
}

// A meter that refuses the read is a fault, not a zero.
func TestAMeterThatRefusesIsAFaultNotAZeroReading(t *testing.T) {
	addr := regPanel(t, map[uint16][]byte{}) // every register read is refused

	got, err := NewModbusClient(2*time.Second).Status(context.Background(),
		&domain.WaterController{
			Protocol: domain.ProtocolModbus,
			Endpoint: addr + "?coil=3&meter_register=200",
		})
	if err != nil {
		t.Fatalf("Status: %v", err)
	}
	if got.HasVolumeTotal {
		t.Error("a refused meter read was reported as a reading")
	}
	if got.Fault == "" {
		t.Error("a refused meter read left no fault to explain the missing volume")
	}
	// The valve state was still read.
	if !got.Online {
		t.Error("the panel was marked offline because only its meter failed")
	}
}

// Register zero is a real address, so "not configured" cannot be represented
// by it. Every panel would otherwise report whatever sits at register 0 as
// its water meter.
func TestRegisterZeroIsAnAddressNotAnAbsence(t *testing.T) {
	ep, err := parseEndpoint("host:502?meter_register=0")
	if err != nil {
		t.Fatalf("parseEndpoint: %v", err)
	}
	reg, ok := ep.registerOpt("meter_register")
	if !ok || reg != 0 {
		t.Errorf("registerOpt = %d, %v; want register 0 to be configured", reg, ok)
	}

	ep, _ = parseEndpoint("host:502")
	if _, ok := ep.registerOpt("meter_register"); ok {
		t.Error("an unset meter_register was read as configured")
	}
}

// A flow rate is one register, and a panel that has one is what makes an
// estimate possible where there is no totaliser.
func TestModbusReadsTheFlowRate(t *testing.T) {
	addr := regPanel(t, map[uint16][]byte{
		300: {0x04, 0xB0}, // 1200 L/h
	})

	got, err := NewModbusClient(2*time.Second).Status(context.Background(),
		&domain.WaterController{
			Protocol: domain.ProtocolModbus,
			Endpoint: addr + "?coil=3&flow_register=300",
		})
	if err != nil {
		t.Fatalf("Status: %v", err)
	}
	if !got.HasFlowRate || got.FlowRateLitersPerHour != 1200 {
		t.Errorf("flow = %v, %v; want 1200", got.FlowRateLitersPerHour, got.HasFlowRate)
	}
}

// LoRaWAN cannot be asked. A downlink is queued for the device's next receive
// window, so there is no synchronous way to read a meter — and reporting one
// anyway would be a fabricated measurement.
func TestLoRaWANReportsNoMeter(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	defer srv.Close()

	client, _ := NewLoRaWANClient(LoRaWANConfig{BaseURL: srv.URL, APIToken: "tok"})
	got, err := client.Status(context.Background(), &domain.WaterController{
		Protocol: domain.ProtocolLoRaWAN, Endpoint: "0004a30b001c0530",
	})
	if err != nil {
		t.Fatalf("Status: %v", err)
	}
	if got.HasVolumeTotal {
		t.Error("LoRaWAN reported a water meter it cannot read")
	}
}
