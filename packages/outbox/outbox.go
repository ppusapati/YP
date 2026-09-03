package outbox

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"go.uber.org/zap"
)

// Publisher implements the EventPublisher port by writing events to an outbox
// table within the caller's database. A separate Relay goroutine picks them
// up and forwards to Kafka (or any downstream transport).
//
// If a pgx.Tx is present in context (set via WithTx), the INSERT runs inside
// that transaction, giving true transactional outbox semantics. Otherwise it
// uses the pool directly — still durable, but not atomically tied to the
// business operation.
type Publisher struct {
	pool   *pgxpool.Pool
	logger *zap.Logger
}

type txKey struct{}

// WithTx stores a pgx.Tx in context so Publisher.Publish can join it.
func WithTx(ctx context.Context, tx pgx.Tx) context.Context {
	return context.WithValue(ctx, txKey{}, tx)
}

func NewPublisher(pool *pgxpool.Pool, logger *zap.Logger) *Publisher {
	return &Publisher{pool: pool, logger: logger}
}

func (p *Publisher) Publish(ctx context.Context, topic, key string, payload []byte) error {
	const q = `INSERT INTO outbox_events (topic, event_key, payload) VALUES ($1, $2, $3)`

	if tx, ok := ctx.Value(txKey{}).(pgx.Tx); ok {
		_, err := tx.Exec(ctx, q, topic, key, payload)
		if err != nil {
			return fmt.Errorf("outbox: insert (tx): %w", err)
		}
		return nil
	}

	_, err := p.pool.Exec(ctx, q, topic, key, payload)
	if err != nil {
		return fmt.Errorf("outbox: insert: %w", err)
	}
	return nil
}

// Event is an outbox row ready for relay.
type Event struct {
	ID      int64
	Topic   string
	Key     string
	Payload []byte
}

// KafkaPublisher is the downstream transport the relay pushes events to.
type KafkaPublisher interface {
	Publish(ctx context.Context, topic, key string, payload []byte) error
}

// Relay polls the outbox table and forwards events to Kafka.
// It runs until the context is cancelled.
type Relay struct {
	pool      *pgxpool.Pool
	publisher KafkaPublisher
	logger    *zap.Logger
	interval  time.Duration
	batchSize int
}

func NewRelay(pool *pgxpool.Pool, publisher KafkaPublisher, logger *zap.Logger) *Relay {
	return &Relay{
		pool:      pool,
		publisher: publisher,
		logger:    logger,
		interval:  500 * time.Millisecond,
		batchSize: 100,
	}
}

// Run starts the relay loop. It blocks until ctx is cancelled.
func (r *Relay) Run(ctx context.Context) {
	r.logger.Info("outbox relay started")
	ticker := time.NewTicker(r.interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			r.logger.Info("outbox relay stopping")
			return
		case <-ticker.C:
			if err := r.poll(ctx); err != nil {
				r.logger.Warn("outbox relay poll error", zap.Error(err))
			}
		}
	}
}

func (r *Relay) poll(ctx context.Context) error {
	rows, err := r.pool.Query(ctx,
		`SELECT id, topic, event_key, payload FROM outbox_events ORDER BY id LIMIT $1`,
		r.batchSize,
	)
	if err != nil {
		return fmt.Errorf("outbox relay: query: %w", err)
	}
	defer rows.Close()

	var events []Event
	for rows.Next() {
		var e Event
		if err := rows.Scan(&e.ID, &e.Topic, &e.Key, &e.Payload); err != nil {
			return fmt.Errorf("outbox relay: scan: %w", err)
		}
		events = append(events, e)
	}
	if err := rows.Err(); err != nil {
		return fmt.Errorf("outbox relay: rows: %w", err)
	}

	for _, e := range events {
		if r.publisher == nil {
			r.logger.Debug("outbox relay: no publisher, discarding", zap.String("topic", e.Topic))
		} else if err := r.publisher.Publish(ctx, e.Topic, e.Key, e.Payload); err != nil {
			r.logger.Warn("outbox relay: publish failed, will retry",
				zap.String("topic", e.Topic), zap.Error(err))
			return nil
		}

		if _, err := r.pool.Exec(ctx, `DELETE FROM outbox_events WHERE id = $1`, e.ID); err != nil {
			r.logger.Warn("outbox relay: delete failed", zap.Int64("id", e.ID), zap.Error(err))
		}
	}

	return nil
}
