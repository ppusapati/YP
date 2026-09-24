package consumer

import (
	"context"
	"testing"
	"time"

	"google.golang.org/protobuf/types/known/anypb"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"p9e.in/samavaya/packages/api/v1/message"
	"p9e.in/samavaya/packages/events/config"
	"p9e.in/samavaya/packages/testutil"
)

// An unreachable broker. Nothing listens here, so sarama fails to build a
// consumer group — which is exactly the situation that used to end the
// process.
const unreachableBroker = "127.0.0.1:1"

func newTestConsumer(t *testing.T) *KafkaConsumer {
	t.Helper()
	return NewKafkaConsumer(&config.KafkaConfig{
		Broker:       unreachableBroker,
		Group:        "test-group",
		KafkaVersion: "3.5.0",
		Assignor:     "sticky",
	}, testutil.NopLogger{})
}

// A broker that cannot be reached is reported, not exited on.
//
// This is the whole point of the change. ConsumerGroup called Fatalf — os.Exit
// inside a library — so a broker that was briefly unreachable at boot took the
// entire service down, including the RPCs it could still have served. If this
// test ever regresses it will not fail: the test binary will exit, and the
// package will report no tests run.
func TestAnUnreachableBrokerIsReportedNotExitedOn(t *testing.T) {
	kc := newTestConsumer(t)
	t.Cleanup(kc.Cleanup)

	group, err := kc.ConsumerGroup("test-group-topic")
	if err == nil {
		t.Fatal("joining a group on an unreachable broker returned no error")
	}
	if group != nil {
		t.Error("a consumer group was returned alongside the error")
	}
	// The error names where it could not reach, because "connection refused"
	// alone tells an operator nothing about which broker.
	if !contains(err.Error(), unreachableBroker) {
		t.Errorf("error %q does not name the broker", err)
	}
}

// Subscribe's error return is real.
//
// It declared one and could never produce one: every path returned nil, and
// the only failure exited the process instead. Thirteen services check this
// error and their warning branch had never run.
func TestSubscribeReturnsTheErrorItDeclares(t *testing.T) {
	kc := newTestConsumer(t)
	t.Cleanup(kc.Cleanup)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	err := kc.Subscribe(ctx, "some.topic", func(context.Context, []byte) error { return nil })
	if err == nil {
		t.Fatal("Subscribe reported success against an unreachable broker")
	}
}

// After Cleanup, subscribing is a no-op rather than an error: the service is
// shutting down, which is not a failure to report.
func TestSubscribingDuringShutdownIsNotAnError(t *testing.T) {
	kc := newTestConsumer(t)
	kc.Cleanup()

	if err := kc.Subscribe(context.Background(), "some.topic",
		func(context.Context, []byte) error { return nil }); err != nil {
		t.Errorf("Subscribe during shutdown returned %v", err)
	}

	group, err := kc.ConsumerGroup("test-group-topic")
	if err != nil || group != nil {
		t.Errorf("ConsumerGroup during shutdown = %v, %v; want nil, nil", group, err)
	}
}

// Consume returns rather than dereferencing a nil consumer group.
//
// It called ConsumerGroup and deferred Close on the result. During shutdown
// that result is nil, so an orderly shutdown panicked on a nil interface.
func TestConsumeDuringShutdownDoesNotPanic(t *testing.T) {
	kc := newTestConsumer(t)
	kc.Cleanup()

	done := make(chan struct{})
	go func() {
		defer close(done)
		kc.Consume(context.Background(), nil)
	}()

	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("Consume did not return during shutdown")
	}
}

// Consume against an unreachable broker returns instead of ending the process.
func TestConsumeOnAnUnreachableBrokerReturns(t *testing.T) {
	kc := newTestConsumer(t)
	t.Cleanup(kc.Cleanup)

	done := make(chan struct{})
	go func() {
		defer close(done)
		kc.Consume(context.Background(), nil)
	}()

	select {
	case <-done:
	case <-time.After(15 * time.Second):
		t.Fatal("Consume did not return for an unreachable broker")
	}
}

// The background retry stops when the context ends, rather than running for
// the life of the process.
//
// Without this the loop outlives the thing that asked for it: a service told
// to shut down would keep dialling a broker on a two-second timer until the
// process was killed.
func TestTheRetryStopsWithTheContext(t *testing.T) {
	kc := newTestConsumer(t)
	t.Cleanup(kc.Cleanup)

	ctx, cancel := context.WithCancel(context.Background())

	done := make(chan struct{})
	go func() {
		defer close(done)
		kc.resubscribe(ctx, "some.topic", func(context.Context, []byte) error { return nil })
	}()

	cancel()

	select {
	case <-done:
	case <-time.After(10 * time.Second):
		t.Fatal("the retry loop outlived its context")
	}
}

// The backoff is bounded, so thirty services retrying a broker that is down
// are not their own outage.
func TestTheBackoffIsBounded(t *testing.T) {
	if reconnectInitial <= 0 {
		t.Error("the first retry is immediate, which is a tight loop against a dead broker")
	}
	if reconnectMax < reconnectInitial {
		t.Error("the cap is below the starting interval")
	}
	if reconnectMax > time.Minute {
		t.Errorf("a cap of %s is long enough that a recovered broker goes unnoticed", reconnectMax)
	}
}

func contains(haystack, needle string) bool {
	return len(needle) > 0 && len(haystack) >= len(needle) &&
		(haystack == needle || indexOf(haystack, needle) >= 0)
}

func indexOf(haystack, needle string) int {
	for i := 0; i+len(needle) <= len(haystack); i++ {
		if haystack[i:i+len(needle)] == needle {
			return i
		}
	}
	return -1
}

// The payload a domain handler receives is the payload that was published.
//
// Reading Any.Value directly worked only by accident for one of the three
// shapes on the wire. For an Any wrapping a StringValue it handed the handler
// the JSON with protobuf framing glued to the front, so json.Unmarshal failed
// on bytes that were never malformed.
func TestThePayloadSurvivesEveryWireFormat(t *testing.T) {
	const published = `{"type":"agriculture.sensor.reading.ingested"}`

	wrapped, err := anypb.New(wrapperspb.String(published))
	if err != nil {
		t.Fatalf("wrapping: %v", err)
	}
	asBytes, err := anypb.New(wrapperspb.Bytes([]byte(published)))
	if err != nil {
		t.Fatalf("wrapping: %v", err)
	}

	cases := []struct {
		name string
		msg  *message.EventMessage
		want string
	}{
		{
			// What the outbox relay puts on the partition, which is what every
			// service in this repository publishes.
			name: "a bare payload",
			msg:  &message.EventMessage{Value: &anypb.Any{Value: []byte(published)}},
			want: published,
		},
		{
			name: "an Any wrapping a StringValue",
			msg:  &message.EventMessage{Value: wrapped},
			want: published,
		},
		{
			name: "an Any wrapping a BytesValue",
			msg:  &message.EventMessage{Value: asBytes},
			want: published,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := string(payloadOf(tc.msg)); got != tc.want {
				t.Errorf("payload = %q, want %q", got, tc.want)
			}
		})
	}
}

// A message with no value at all yields nothing rather than panicking.
func TestAnEmptyMessageHasNoPayload(t *testing.T) {
	if got := payloadOf(&message.EventMessage{}); len(got) != 0 {
		t.Errorf("payload = %q, want empty", got)
	}
}
