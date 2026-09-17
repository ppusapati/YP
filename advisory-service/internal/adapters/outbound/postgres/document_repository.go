// Package postgres implements advisory-service's repository ports using pgx.
package postgres

import (
	"context"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	p9errors "p9e.in/samavaya/packages/errors"
	"p9e.in/samavaya/packages/p9log"

	"p9e.in/samavaya/agriculture/advisory-service/internal/domain"
	"p9e.in/samavaya/agriculture/advisory-service/internal/ports/outbound"
)

type documentRepository struct {
	pool *pgxpool.Pool
	log  *p9log.Helper
}

// NewDocumentRepository creates a postgres-backed DocumentRepository.
func NewDocumentRepository(pool *pgxpool.Pool, log p9log.Logger) outbound.DocumentRepository {
	return &documentRepository{
		pool: pool,
		log:  p9log.NewHelper(p9log.With(log, "component", "AdvisoryDocumentRepository")),
	}
}

const documentColumns = `
	id, tenant_id, title, kind, locale, source, uri, crops, region,
	chunk_count, created_at`

// CreateDocument writes the document and its chunks in one transaction.
//
// One transaction because a document row with no chunks is a document that
// appears in the library, reports a chunk count, and can never be retrieved —
// the worst of the three possible outcomes, because it looks like the corpus
// contains something it does not.
func (r *documentRepository) CreateDocument(
	ctx context.Context,
	d *domain.ReferenceDocument,
	chunks []domain.Chunk,
) (*domain.ReferenceDocument, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, p9errors.InternalServer("DOCUMENT_TX_FAILED", "an internal error occurred")
	}
	defer tx.Rollback(ctx) //nolint:errcheck

	if _, err := tx.Exec(ctx, `
		INSERT INTO advisory_documents (
			id, tenant_id, title, kind, locale, source, uri, crops, region,
			chunk_count, embedder, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)`,
		d.ID, d.TenantID, d.Title, string(d.Kind), string(d.Locale), d.Source, d.URI,
		d.Crops, d.Region, len(chunks), d.Embedder, d.CreatedBy,
	); err != nil {
		r.log.Errorw("msg", "failed to insert document", "error", err)
		return nil, p9errors.InternalServer("DOCUMENT_INSERT_FAILED", "an internal error occurred")
	}

	for _, chunk := range chunks {
		var embedding any
		if len(chunk.Embedding) > 0 {
			embedding = domain.VectorLiteral(chunk.Embedding)
		}
		if _, err := tx.Exec(ctx, `
			INSERT INTO advisory_chunks (id, tenant_id, document_id, ordinal, body, embedding)
			VALUES ($1,$2,$3,$4,$5,$6::vector)`,
			chunk.ID, chunk.TenantID, d.ID, chunk.Ordinal, chunk.Text, embedding,
		); err != nil {
			r.log.Errorw("msg", "failed to insert chunk", "error", err, "ordinal", chunk.Ordinal)
			return nil, p9errors.InternalServer("CHUNK_INSERT_FAILED", "an internal error occurred")
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return nil, p9errors.InternalServer("DOCUMENT_COMMIT_FAILED", "an internal error occurred")
	}

	d.ChunkCount = len(chunks)
	return d, nil
}

func (r *documentRepository) ListDocuments(
	ctx context.Context,
	params domain.ListDocumentsParams,
) ([]domain.ReferenceDocument, int64, error) {
	limit, offset := domain.ClampPage(params.Limit, params.Offset)

	where := []string{"tenant_id = $1"}
	args := []any{params.TenantID}

	if params.Locale.IsSupported() {
		args = append(args, string(params.Locale))
		where = append(where, fmt.Sprintf("locale = $%d", len(args)))
	}
	if params.Crop != "" {
		args = append(args, params.Crop)
		where = append(where, fmt.Sprintf("$%d = ANY(crops)", len(args)))
	}
	if params.Region != "" {
		args = append(args, params.Region)
		where = append(where, fmt.Sprintf("region = $%d", len(args)))
	}
	clause := strings.Join(where, " AND ")

	var total int64
	if err := r.pool.QueryRow(ctx,
		`SELECT COUNT(*) FROM advisory_documents WHERE `+clause, args...,
	).Scan(&total); err != nil {
		return nil, 0, p9errors.InternalServer("DOCUMENT_COUNT_FAILED", "an internal error occurred")
	}

	args = append(args, limit, offset)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(
		`SELECT %s FROM advisory_documents WHERE %s ORDER BY created_at DESC LIMIT $%d OFFSET $%d`,
		documentColumns, clause, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, 0, p9errors.InternalServer("DOCUMENT_LIST_FAILED", "an internal error occurred")
	}
	defer rows.Close()

	var out []domain.ReferenceDocument
	for rows.Next() {
		d, err := scanDocument(rows)
		if err != nil {
			return nil, 0, p9errors.InternalServer("DOCUMENT_SCAN_FAILED", "an internal error occurred")
		}
		out = append(out, *d)
	}
	return out, total, rows.Err()
}

func (r *documentRepository) DeleteDocument(ctx context.Context, id, tenantID string) (bool, error) {
	tag, err := r.pool.Exec(ctx,
		`DELETE FROM advisory_documents WHERE id = $1 AND tenant_id = $2`, id, tenantID)
	if err != nil {
		return false, p9errors.InternalServer("DOCUMENT_DELETE_FAILED", "an internal error occurred")
	}
	return tag.RowsAffected() > 0, nil
}

// SearchChunks runs a vector search and a full-text search and fuses them.
//
// Two queries rather than one, and fused by rank rather than by raw score.
// Cosine distance and ts_rank are on incomparable scales — one is bounded in
// [0,2] and the other is an unbounded relevance figure — so adding or
// averaging them weights whichever happens to be larger, not whichever is more
// relevant. Reciprocal rank fusion only uses each list's *ordering*, which is
// the part of each score that means something.
//
// The lexical half runs even when there is a vector, because an embedding will
// rank a passage about a different crop highly on topical similarity alone,
// and the words the farmer actually typed are the check on that.
func (r *documentRepository) SearchChunks(ctx context.Context, q outbound.ChunkQuery) ([]domain.Citation, error) {
	if q.TenantID == "" {
		return nil, p9errors.BadRequest("MISSING_TENANT", "tenant is required")
	}
	limit := q.Limit
	if limit <= 0 {
		limit = domain.MaxCitations
	}
	// Each half retrieves deeper than the final list so fusion has something
	// to work with: if both halves returned exactly the final count, fusion
	// would be a no-op on already-identical lists.
	depth := limit * 4

	fused := map[string]*domain.Citation{}
	ranks := map[string]float64{}

	addRanked := func(hits []domain.Citation) {
		for i, hit := range hits {
			citation := hit
			if _, ok := fused[citation.ID]; !ok {
				fused[citation.ID] = &citation
			}
			// The constant damps the difference between the top few positions,
			// so a passage that is second in both lists beats one that is
			// first in one and absent from the other — which is the behaviour
			// wanted here, where agreement between two different notions of
			// relevance is the signal.
			ranks[citation.ID] += 1 / float64(60+i+1)
		}
	}

	if len(q.Vector) > 0 {
		hits, err := r.vectorSearch(ctx, q, depth)
		if err != nil {
			return nil, err
		}
		addRanked(hits)
	}

	lexical, err := r.lexicalSearch(ctx, q, depth)
	if err != nil {
		return nil, err
	}
	addRanked(lexical)

	out := make([]domain.Citation, 0, len(fused))
	for id, citation := range fused {
		citation.Score = ranks[id]
		out = append(out, *citation)
	}
	// Ordering is left to RankCitations, which blends in lexical overlap and
	// locale. Returning more than the caller asked for is deliberate: it is the
	// ranker's job to choose, not the store's.
	return out, nil
}

func (r *documentRepository) vectorSearch(
	ctx context.Context,
	q outbound.ChunkQuery,
	depth int,
) ([]domain.Citation, error) {
	args := []any{q.TenantID, domain.VectorLiteral(q.Vector)}
	filter, args := documentFilter(q, args)

	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT c.id, c.tenant_id, c.body, d.id, d.title, d.locale, d.source, d.uri
		FROM advisory_chunks c
		JOIN advisory_documents d ON d.id = c.document_id
		WHERE c.tenant_id = $1 AND c.embedding IS NOT NULL %s
		ORDER BY c.embedding <=> $2::vector
		LIMIT %d`, filter, depth), args...)
	if err != nil {
		r.log.Errorw("msg", "vector search failed", "error", err)
		return nil, p9errors.InternalServer("VECTOR_SEARCH_FAILED", "an internal error occurred")
	}
	defer rows.Close()
	return scanCitations(rows)
}

func (r *documentRepository) lexicalSearch(
	ctx context.Context,
	q outbound.ChunkQuery,
	depth int,
) ([]domain.Citation, error) {
	if strings.TrimSpace(q.QueryText) == "" {
		return nil, nil
	}
	// 'simple' rather than a language configuration. PostgreSQL ships stemmers
	// for English and a dozen European languages and none for Hindi, Marathi,
	// Telugu, Tamil, Kannada, Punjabi or Bengali; asking for 'english' on a
	// Telugu corpus applies English stop-words and English stemming to it,
	// which is worse than not stemming at all.
	args := []any{q.TenantID, q.QueryText}
	filter, args := documentFilter(q, args)

	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT c.id, c.tenant_id, c.body, d.id, d.title, d.locale, d.source, d.uri
		FROM advisory_chunks c
		JOIN advisory_documents d ON d.id = c.document_id
		WHERE c.tenant_id = $1
		  AND c.body_tsv @@ plainto_tsquery('simple', $2) %s
		ORDER BY ts_rank(c.body_tsv, plainto_tsquery('simple', $2)) DESC
		LIMIT %d`, filter, depth), args...)
	if err != nil {
		r.log.Errorw("msg", "lexical search failed", "error", err)
		return nil, p9errors.InternalServer("LEXICAL_SEARCH_FAILED", "an internal error occurred")
	}
	defer rows.Close()
	return scanCitations(rows)
}

// documentFilter narrows a search to a crop or region when one was given.
func documentFilter(q outbound.ChunkQuery, args []any) (string, []any) {
	var clauses []string
	if q.Crop != "" {
		args = append(args, q.Crop)
		// Documents with no crops listed are general material and stay in the
		// result. Filtering them out would mean a question about wheat never
		// retrieves the general soil-health guide that answers it.
		clauses = append(clauses, fmt.Sprintf("(cardinality(d.crops) = 0 OR $%d = ANY(d.crops))", len(args)))
	}
	if q.Region != "" {
		args = append(args, q.Region)
		clauses = append(clauses, fmt.Sprintf("(d.region = '' OR d.region = $%d)", len(args)))
	}
	if len(clauses) == 0 {
		return "", args
	}
	return " AND " + strings.Join(clauses, " AND "), args
}

func scanCitations(rows pgx.Rows) ([]domain.Citation, error) {
	var out []domain.Citation
	for rows.Next() {
		var (
			chunkID, tenantID, body string
			docID, title, locale    string
			source, uri             string
		)
		if err := rows.Scan(&chunkID, &tenantID, &body, &docID, &title, &locale, &source, &uri); err != nil {
			return nil, err
		}
		out = append(out, domain.Citation{
			ID:       chunkID,
			TenantID: tenantID,
			Kind:     domain.CitationDocument,
			// The source is part of the title rather than a separate field in
			// the prompt: "ICAR package of practices" and "an unattributed
			// PDF" support a recommendation differently, and a model shown
			// only the title cannot tell them apart.
			Title:    strings.TrimSpace(title + " — " + source),
			Snippet:  domain.Snippet(body, 1200),
			URI:      uri,
			SourceID: docID,
			Locale:   domain.Locale(locale),
		})
	}
	return out, rows.Err()
}

func scanDocument(row pgx.Row) (*domain.ReferenceDocument, error) {
	var d domain.ReferenceDocument
	var kind, locale string
	if err := row.Scan(
		&d.ID, &d.TenantID, &d.Title, &kind, &locale, &d.Source, &d.URI,
		&d.Crops, &d.Region, &d.ChunkCount, &d.CreatedAt,
	); err != nil {
		return nil, err
	}
	d.Kind = domain.DocumentKind(kind)
	d.Locale = domain.Locale(locale)
	return &d, nil
}
