package handler

import (
	"context"
	"testing"
	"time"

	msgp "p9e.in/samavaya/packages/api/v1/message"
	"p9e.in/samavaya/packages/testutil"

	"github.com/IBM/sarama"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/anypb"
)

// Bytes that are not a protobuf EventMessage. JSON is the realistic case:
// anything publishing to one of these topics with a different serialisation —
// a console producer, another team's service, a replay tool — puts exactly
// this on the partition.
var notProtobuf = []byte(`{"id":"evt-1","type":"agriculture.sensor.reading.ingested"}`)

type fakeClaim struct {
	messages chan *sarama.ConsumerMessage
}

func (c *fakeClaim) Topic() string                            { return "some.topic" }
func (c *fakeClaim) Partition() int32                         { return 0 }
func (c *fakeClaim) InitialOffset() int64                     { return 0 }
func (c *fakeClaim) HighWaterMarkOffset() int64               { return 0 }
func (c *fakeClaim) Messages() <-chan *sarama.ConsumerMessage { return c.messages }

type fakeSession struct {
	marked []int64
}

func (s *fakeSession) Claims() map[string][]int32               { return nil }
func (s *fakeSession) MemberID() string                         { return "test-member" }
func (s *fakeSession) GenerationID() int32                      { return 1 }
func (s *fakeSession) MarkOffset(string, int32, int64, string)  {}
func (s *fakeSession) ResetOffset(string, int32, int64, string) {}
func (s *fakeSession) Commit()                                  {}
func (s *fakeSession) Context() context.Context                 { return context.Background() }
func (s *fakeSession) MarkMessage(msg *sarama.ConsumerMessage, _ string) {
	s.marked = append(s.marked, msg.Offset)
}

// runClaim feeds msgs through ConsumeClaim and returns what reached the
// downstream channel, along with the session so offsets can be inspected.
func runClaim(t *testing.T, h *KafkaHandler, msgs ...*sarama.ConsumerMessage) ([]*msgp.EventMessage, *fakeSession) {
	t.Helper()

	claim := &fakeClaim{messages: make(chan *sarama.ConsumerMessage, len(msgs))}
	for _, m := range msgs {
		claim.messages <- m
	}
	close(claim.messages)

	session := &fakeSession{}

	// The handler writes to an unbuffered channel, so drain it concurrently.
	var forwarded []*msgp.EventMessage
	drained := make(chan struct{})
	go func() {
		defer close(drained)
		for m := range h.KafkaMessages {
			forwarded = append(forwarded, m)
		}
	}()

	done := make(chan error, 1)
	go func() { done <- h.ConsumeClaim(session, claim) }()

	select {
	case err := <-done:
		if err != nil {
			t.Fatalf("ConsumeClaim returned %v", err)
		}
	case <-time.After(5 * time.Second):
		t.Fatal("ConsumeClaim did not return")
	}

	close(h.KafkaMessages)
	<-drained
	return forwarded, session
}

func consumerMessage(offset int64, value []byte) *sarama.ConsumerMessage {
	return &sarama.ConsumerMessage{Topic: "some.topic", Partition: 0, Offset: offset, Value: value}
}

// A bare payload does not take the process down.
//
// The consumer package built its handler as a struct literal, which left the
// log field unset, and the only code that touched it was the branch reached
// when a message is not an EventMessage. That branch looked exotic; it is in
// fact the common case, because the outbox relay every service publishes
// through puts the payload on the partition unwrapped. So the first real
// cross-service event dereferenced a nil logger inside a sarama goroutine and
// killed the whole service, not just the consumer — and since the offset never
// advanced, every restart re-read the same message and died again.
//
// If this regresses the test will not report a failure — the test binary will
// panic and the package will report no tests run at all.
func TestABarePayloadDoesNotCrashALiteralHandler(t *testing.T) {
	h := &KafkaHandler{KafkaMessages: make(chan *msgp.EventMessage)}

	_, session := runClaim(t, h, consumerMessage(7, notProtobuf))

	if len(session.marked) != 1 || session.marked[0] != 7 {
		t.Errorf("message was not marked; marked offsets = %v", session.marked)
	}
}

// A bare payload reaches the downstream handler with its bytes intact.
//
// This is the delivery path for every event this repository actually
// publishes. Dropping these, or forwarding the zero-value message that used to
// go out alongside the log line, means no cross-service event is ever handled.
func TestABarePayloadIsCarriedThroughUnchanged(t *testing.T) {
	h := NewKafkaHandler(testutil.NopLogger{})

	forwarded, session := runClaim(t, h, consumerMessage(3, notProtobuf))

	if len(forwarded) != 1 {
		t.Fatalf("forwarded %d messages, want the bare payload carried through", len(forwarded))
	}
	if got := string(forwarded[0].GetValue().GetValue()); got != string(notProtobuf) {
		t.Errorf("payload = %q, want %q", got, notProtobuf)
	}
	// The envelope is reconstructed from the Kafka message, so a downstream
	// reader still knows where the event came from.
	if forwarded[0].GetTopic() != "some.topic" || forwarded[0].GetOffset() != 3 {
		t.Errorf("envelope = topic %q offset %d, want some.topic/3",
			forwarded[0].GetTopic(), forwarded[0].GetOffset())
	}
	if len(session.marked) != 1 {
		t.Errorf("marked offsets = %v, want the message marked once", session.marked)
	}
}

// A valid message is still delivered — the skip above must not swallow good
// traffic.
func TestAValidMessageIsStillForwardedAndMarked(t *testing.T) {
	h := NewKafkaHandler(testutil.NopLogger{})

	payload, err := anypb.New(&msgp.EventMessage{Key: "inner"})
	if err != nil {
		t.Fatalf("building payload: %v", err)
	}
	raw, err := proto.Marshal(&msgp.EventMessage{
		Key: "evt-1", Topic: "some.topic", Partition: 0, Offset: 11, Value: payload,
	})
	if err != nil {
		t.Fatalf("marshalling: %v", err)
	}

	forwarded, session := runClaim(t, h, consumerMessage(11, raw))

	if len(forwarded) != 1 {
		t.Fatalf("forwarded %d messages, want 1", len(forwarded))
	}
	if forwarded[0].GetKey() != "evt-1" {
		t.Errorf("forwarded key = %q, want evt-1", forwarded[0].GetKey())
	}
	if len(session.marked) != 1 || session.marked[0] != 11 {
		t.Errorf("marked offsets = %v, want [11]", session.marked)
	}
}

// Both wire formats can share a partition, because nothing stops one service
// publishing through the outbox while another uses producer.ProduceMessage.
func TestBothWireFormatsSurviveTheSameClaim(t *testing.T) {
	h := NewKafkaHandler(testutil.NopLogger{})

	enveloped, err := proto.Marshal(&msgp.EventMessage{Key: "enveloped"})
	if err != nil {
		t.Fatalf("marshalling: %v", err)
	}

	forwarded, session := runClaim(t, h,
		consumerMessage(1, notProtobuf),
		consumerMessage(2, enveloped),
	)

	if len(forwarded) != 2 {
		t.Fatalf("forwarded %d messages, want both", len(forwarded))
	}
	if got := string(forwarded[0].GetValue().GetValue()); got != string(notProtobuf) {
		t.Errorf("bare payload = %q, want %q", got, notProtobuf)
	}
	if forwarded[1].GetKey() != "enveloped" {
		t.Errorf("enveloped key = %q, want enveloped", forwarded[1].GetKey())
	}
	if len(session.marked) != 2 {
		t.Errorf("marked offsets = %v, want both messages marked", session.marked)
	}
}
