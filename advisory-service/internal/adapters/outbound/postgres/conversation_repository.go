package postgres

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

type conversationRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewConversationRepository creates a postgres-backed ConversationRepository.
func NewConversationRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.ConversationRepository {
	return &conversationRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "AdvisoryConversationRepository")),
	}
}

const conversationColumns = `
	id, tenant_id, title, field_id, farm_id, locale, exchange_count,
	created_by, created_at, updated_at`

const exchangeColumns = `
	id, tenant_id, conversation_id, question, answer, locale, answer_kind,
	citations, tool_calls, evaluation, usage, needs_review, groundedness,
	reviewed, reviewer_note, rating, reviewed_by, reviewed_at,
	asked_by, created_at`

func (r *conversationRepository) CreateConversation(
	ctx context.Context,
	c *domain.Conversation,
) (*domain.Conversation, error) {
	row := r.pool.QueryRow(ctx, fmt.Sprintf(`
		INSERT INTO advisory_conversations (
			id, tenant_id, title, field_id, farm_id, locale, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7)
		RETURNING %s`, conversationColumns),
		c.ID, c.TenantID, c.Title, c.FieldID, c.FarmID, string(c.Locale), c.CreatedBy)

	got, err := scanConversation(row)
	if err != nil {
		r.log.Errorw("msg", "failed to create conversation", "error", err)
		return nil, p9errors.InternalServer("CONVERSATION_INSERT_FAILED", "an internal error occurred")
	}
	return got, nil
}

func (r *conversationRepository) GetConversation(ctx context.Context, id, tenantID string) (*domain.Conversation, error) {
	row := r.pool.QueryRow(ctx, fmt.Sprintf(
		`SELECT %s FROM advisory_conversations WHERE id = $1 AND tenant_id = $2`,
		conversationColumns), id, tenantID)

	got, err := scanConversation(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, p9errors.NotFound("CONVERSATION_NOT_FOUND", "conversation not found")
	}
	if err != nil {
		return nil, p9errors.InternalServer("CONVERSATION_GET_FAILED", "an internal error occurred")
	}
	return got, nil
}

func (r *conversationRepository) ListConversations(
	ctx context.Context,
	params domain.ListConversationsParams,
) ([]domain.Conversation, int64, error) {
	limit, offset := domain.ClampPage(params.Limit, params.Offset)

	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}
	if params.FieldID != "" {
		args = append(args, params.FieldID)
		where = append(where, fmt.Sprintf("field_id = $%d", len(args)))
	}
	if params.FarmID != "" {
		args = append(args, params.FarmID)
		where = append(where, fmt.Sprintf("farm_id = $%d", len(args)))
	}
	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM advisory_conversations WHERE `+clause, args...).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("CONVERSATION_COUNT_FAILED", "an internal error occurred")
	}

	args = append(args, limit, offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(
		`SELECT %s FROM advisory_conversations WHERE %s ORDER BY updated_at DESC LIMIT $%d OFFSET $%d`,
		conversationColumns, clause, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("CONVERSATION_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.Conversation
	for rows.Next() {
		c, err := scanConversation(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("CONVERSATION_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *c)
	}
	return out, total, rows.Err()
}

func (r *conversationRepository) TouchConversation(ctx context.Context, id, tenantID string, at time.Time) error {
	if _, err := r.pool.Exec(ctx, `
		UPDATE advisory_conversations
		SET updated_at = $3, exchange_count = exchange_count + 1
		WHERE id = $1 AND tenant_id = $2`, id, tenantID, at); err != nil {
		return p9errors.InternalServer("CONVERSATION_TOUCH_FAILED", "an internal error occurred")
	}
	return nil
}

// AppendExchange stores one exchange with everything that produced it.
func (r *conversationRepository) AppendExchange(ctx context.Context, e *domain.Exchange) (*domain.Exchange, error) {
	citations, toolCalls, evaluation, usage, err := encodeExchange(e)
	if err != nil {
		return nil, p9errors.InternalServer("EXCHANGE_ENCODE_FAILED", "an internal error occurred")
	}

	row := r.pool.QueryRow(ctx, fmt.Sprintf(`
		INSERT INTO advisory_exchanges (
			id, tenant_id, conversation_id, question, answer, locale, answer_kind,
			citations, tool_calls, evaluation, usage,
			needs_review, groundedness, cost_micros, latency_ms, asked_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
		RETURNING %s`, exchangeColumns),
		e.ID, e.TenantID, e.ConversationID, e.Question, e.Answer,
		string(e.Locale), string(e.AnswerKind),
		citations, toolCalls, evaluation, usage,
		e.Evaluation.NeedsReview, e.Evaluation.Groundedness,
		e.Usage.CostMicros, e.Usage.Latency.Milliseconds(), e.AskedBy)

	got, err := scanExchange(row)
	if err != nil {
		r.log.Errorw("msg", "failed to append exchange", "error", err)
		return nil, p9errors.InternalServer("EXCHANGE_INSERT_FAILED", "an internal error occurred")
	}
	return got, nil
}

func (r *conversationRepository) GetExchange(ctx context.Context, id, tenantID string) (*domain.Exchange, error) {
	row := r.pool.QueryRow(ctx, fmt.Sprintf(
		`SELECT %s FROM advisory_exchanges WHERE id = $1 AND tenant_id = $2`,
		exchangeColumns), id, tenantID)

	got, err := scanExchange(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, p9errors.NotFound("EXCHANGE_NOT_FOUND", "exchange not found")
	}
	if err != nil {
		return nil, p9errors.InternalServer("EXCHANGE_GET_FAILED", "an internal error occurred")
	}
	return got, nil
}

func (r *conversationRepository) ListExchanges(
	ctx context.Context,
	params domain.ListExchangesParams,
) ([]domain.Exchange, int64, error) {
	limit, offset := domain.ClampPage(params.Limit, params.Offset)

	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}
	if params.ConversationID != "" {
		args = append(args, params.ConversationID)
		where = append(where, fmt.Sprintf("conversation_id = $%d", len(args)))
	}
	if params.NeedsReview {
		where = append(where, "needs_review")
	}
	if params.Unreviewed {
		where = append(where, "NOT reviewed")
	}
	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM advisory_exchanges WHERE `+clause, args...).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("EXCHANGE_COUNT_FAILED", "an internal error occurred")
	}

	// Oldest first inside a conversation, newest first in the review queue.
	// A conversation read bottom-up is unreadable; a review queue that shows
	// the oldest unreviewed answer first is a queue nobody reaches the end of.
	order := "created_at DESC"
	if params.ConversationID != "" {
		order = "created_at ASC"
	}

	args = append(args, limit, offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(
		`SELECT %s FROM advisory_exchanges WHERE %s ORDER BY %s LIMIT $%d OFFSET $%d`,
		exchangeColumns, clause, order, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("EXCHANGE_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.Exchange
	for rows.Next() {
		e, err := scanExchange(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("EXCHANGE_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *e)
	}
	return out, total, rows.Err()
}

func (r *conversationRepository) ReviewExchange(
	ctx context.Context,
	id, tenantID, reviewer, note string,
	rating int,
	at time.Time,
) (*domain.Exchange, error) {
	row := r.pool.QueryRow(ctx, fmt.Sprintf(`
		UPDATE advisory_exchanges
		SET reviewed = TRUE, reviewer_note = $3, rating = $4, reviewed_by = $5, reviewed_at = $6
		WHERE id = $1 AND tenant_id = $2
		RETURNING %s`, exchangeColumns),
		id, tenantID, note, rating, reviewer, at)

	got, err := scanExchange(row)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, p9errors.NotFound("EXCHANGE_NOT_FOUND", "exchange not found")
	}
	if err != nil {
		return nil, p9errors.InternalServer("EXCHANGE_REVIEW_FAILED", "an internal error occurred")
	}
	return got, nil
}

// ── Scanning ─────────────────────────────────────────────────────────────────

func scanConversation(row pgx.Row) (*domain.Conversation, error) {
	var c domain.Conversation
	var locale string
	if err := row.Scan(
		&c.ID, &c.TenantID, &c.Title, &c.FieldID, &c.FarmID, &locale,
		&c.ExchangeCount, &c.CreatedBy, &c.CreatedAt, &c.UpdatedAt,
	); err != nil {
		return nil, err
	}
	c.Locale = domain.Locale(locale)
	return &c, nil
}

func encodeExchange(e *domain.Exchange) (citations, toolCalls, evaluation, usage []byte, err error) {
	// Never nil: the columns are NOT NULL with a JSON default, and a Go nil
	// slice marshals to `null`, which is not `[]` and fails the scan on the
	// way back out.
	if e.Citations == nil {
		e.Citations = []domain.Citation{}
	}
	if e.ToolCalls == nil {
		e.ToolCalls = []domain.ToolCall{}
	}
	if citations, err = json.Marshal(e.Citations); err != nil {
		return nil, nil, nil, nil, err
	}
	if toolCalls, err = json.Marshal(e.ToolCalls); err != nil {
		return nil, nil, nil, nil, err
	}
	if evaluation, err = json.Marshal(e.Evaluation); err != nil {
		return nil, nil, nil, nil, err
	}
	if usage, err = json.Marshal(e.Usage); err != nil {
		return nil, nil, nil, nil, err
	}
	return citations, toolCalls, evaluation, usage, nil
}

func scanExchange(row pgx.Row) (*domain.Exchange, error) {
	var e domain.Exchange
	var locale, answerKind string
	var citations, toolCalls, evaluation, usage []byte
	var groundedness float32
	var needsReview bool

	if err := row.Scan(
		&e.ID, &e.TenantID, &e.ConversationID, &e.Question, &e.Answer,
		&locale, &answerKind,
		&citations, &toolCalls, &evaluation, &usage,
		&needsReview, &groundedness,
		&e.Reviewed, &e.ReviewerNote, &e.Rating, &e.ReviewedBy, &e.ReviewedAt,
		&e.AskedBy, &e.CreatedAt,
	); err != nil {
		return nil, err
	}

	e.Locale = domain.Locale(locale)
	e.AnswerKind = domain.AnswerKind(answerKind)

	// A row whose JSON will not decode is returned with the rest intact. The
	// answer and the question are the parts a reviewer most needs to see, and
	// failing the read would hide the exchange entirely — which is the worst
	// outcome for a log whose purpose is that nothing goes unseen.
	_ = json.Unmarshal(citations, &e.Citations)
	_ = json.Unmarshal(toolCalls, &e.ToolCalls)
	_ = json.Unmarshal(evaluation, &e.Evaluation)
	_ = json.Unmarshal(usage, &e.Usage)

	// The lifted columns are authoritative over the JSON copy: they are what
	// the review queue's index filters on, so a disagreement between the two
	// has to resolve in favour of the one that decided the row was listed.
	e.Evaluation.NeedsReview = needsReview
	e.Evaluation.Groundedness = float64(groundedness)

	return &e, nil
}
