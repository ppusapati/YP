-- ============================================================================
-- Advisory Service: Initial Schema Migration (UP)
-- ============================================================================
--
-- This service needs pgvector, and it says so here rather than degrading.
--
-- The shared TimescaleDB instance the other services use does not ship the
-- vector extension, which is why docker-compose gives advisory-service its own
-- pgvector-based PostgreSQL. A migration that caught the failure and carried on
-- with a text column would leave a service that starts, accepts documents,
-- answers questions and retrieves nothing relevant — working from the outside
-- and useless from the inside. Failing here, loudly, on the first boot against
-- a database without the extension is the cheaper failure by a long way.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS vector;

-- ── Reference corpus ────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS advisory_documents (
    id           CHAR(26)    PRIMARY KEY,
    tenant_id    CHAR(26)    NOT NULL,

    title        TEXT        NOT NULL,
    kind         TEXT        NOT NULL,
    locale       TEXT        NOT NULL DEFAULT 'en',
    source       TEXT        NOT NULL,
    uri          TEXT        NOT NULL DEFAULT '',
    crops        TEXT[]      NOT NULL DEFAULT '{}',
    region       TEXT        NOT NULL DEFAULT '',

    chunk_count  INTEGER     NOT NULL DEFAULT 0,

    -- Which embedder indexed it. A corpus half-indexed by the lexical fallback
    -- and half by a hosted model retrieves badly in a way that looks like a
    -- content problem, and without this column there is nothing to tell them
    -- apart after the fact.
    embedder     TEXT        NOT NULL DEFAULT '',

    created_by   TEXT        NOT NULL DEFAULT 'system',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_advisory_documents_title CHECK (length(btrim(title)) > 0),
    CONSTRAINT chk_advisory_documents_source CHECK (length(btrim(source)) > 0)
);

CREATE INDEX IF NOT EXISTS idx_advisory_documents_tenant
    ON advisory_documents (tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_advisory_documents_crops
    ON advisory_documents USING GIN (crops);

CREATE TABLE IF NOT EXISTS advisory_chunks (
    id           CHAR(26)    PRIMARY KEY,
    tenant_id    CHAR(26)    NOT NULL,
    document_id  CHAR(26)    NOT NULL REFERENCES advisory_documents(id) ON DELETE CASCADE,

    ordinal      INTEGER     NOT NULL,
    body         TEXT        NOT NULL,

    -- 384 dimensions, fixed. pgvector requires a declared width, and changing
    -- it means reindexing the whole corpus; the width is therefore part of the
    -- schema rather than a runtime setting, and a vector of the wrong width is
    -- rejected at insert rather than truncated. A truncated vector still has a
    -- cosine similarity, and the nonsense it produces is indistinguishable
    -- from a weak match.
    embedding    vector(384),

    -- A generated tsvector alongside the embedding. The lexical side of the
    -- search is not a fallback for when the vector is missing — it runs every
    -- time and is blended in, because a hashed or small embedding will happily
    -- rank a passage about a different crop highly, and requiring that the
    -- passage actually contains some of the words asked about is what stops
    -- that being cited as though it were about this one.
    body_tsv     TSVECTOR GENERATED ALWAYS AS (to_tsvector('simple', body)) STORED,

    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_advisory_chunks UNIQUE (document_id, ordinal)
);

CREATE INDEX IF NOT EXISTS idx_advisory_chunks_tenant
    ON advisory_chunks (tenant_id, document_id);
CREATE INDEX IF NOT EXISTS idx_advisory_chunks_tsv
    ON advisory_chunks USING GIN (body_tsv);

-- No ivfflat/hnsw index at migration time, deliberately.
--
-- ivfflat has to be built on a populated table — built on an empty one it
-- produces a single list, and every query then scans everything while
-- appearing to use an index. An exact scan over a corpus of a few thousand
-- chunks is milliseconds, and `scripts/build-vector-index.sql` creates the
-- approximate index once a corpus exists and is worth approximating.

-- ── Conversations ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS advisory_conversations (
    id             CHAR(26)    PRIMARY KEY,
    tenant_id      CHAR(26)    NOT NULL,

    title          TEXT        NOT NULL DEFAULT '',
    field_id       CHAR(26)    NOT NULL DEFAULT '',
    farm_id        CHAR(26)    NOT NULL DEFAULT '',
    locale         TEXT        NOT NULL DEFAULT 'en',

    exchange_count INTEGER     NOT NULL DEFAULT 0,

    created_by     TEXT        NOT NULL DEFAULT 'system',
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_advisory_conversations_tenant
    ON advisory_conversations (tenant_id, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_advisory_conversations_field
    ON advisory_conversations (tenant_id, field_id, updated_at DESC);

CREATE TABLE IF NOT EXISTS advisory_exchanges (
    id              CHAR(26)    PRIMARY KEY,
    tenant_id       CHAR(26)    NOT NULL,
    conversation_id CHAR(26)    NOT NULL REFERENCES advisory_conversations(id) ON DELETE CASCADE,

    question        TEXT        NOT NULL,
    answer          TEXT        NOT NULL,
    locale          TEXT        NOT NULL DEFAULT 'en',
    answer_kind     TEXT        NOT NULL DEFAULT 'GENERATED',

    -- Stored as written, not recomputed on read. The whole point of the log is
    -- that a reviewer sees what the model was actually given; regenerating the
    -- context from today's corpus would show them what it *would* be given
    -- now, which is a different question and a useless answer to the one they
    -- are asking.
    citations       JSONB       NOT NULL DEFAULT '[]',
    tool_calls      JSONB       NOT NULL DEFAULT '[]',
    evaluation      JSONB       NOT NULL DEFAULT '{}',
    usage           JSONB       NOT NULL DEFAULT '{}',

    -- Lifted out of the evaluation JSON so the review queue is an index scan
    -- rather than a full-table JSON predicate.
    needs_review    BOOLEAN     NOT NULL DEFAULT FALSE,
    groundedness    REAL        NOT NULL DEFAULT 0,
    cost_micros     BIGINT      NOT NULL DEFAULT 0,
    latency_ms      BIGINT      NOT NULL DEFAULT 0,

    reviewed        BOOLEAN     NOT NULL DEFAULT FALSE,
    reviewer_note   TEXT        NOT NULL DEFAULT '',
    rating          SMALLINT    NOT NULL DEFAULT 0,
    reviewed_by     TEXT        NOT NULL DEFAULT '',
    reviewed_at     TIMESTAMPTZ,

    asked_by        TEXT        NOT NULL DEFAULT '',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_advisory_exchanges_rating CHECK (rating BETWEEN 0 AND 5)
);

CREATE INDEX IF NOT EXISTS idx_advisory_exchanges_conversation
    ON advisory_exchanges (tenant_id, conversation_id, created_at);
CREATE INDEX IF NOT EXISTS idx_advisory_exchanges_review_queue
    ON advisory_exchanges (tenant_id, created_at DESC)
    WHERE needs_review AND NOT reviewed;

-- ── Budgets ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS advisory_budgets (
    tenant_id                 CHAR(26)    PRIMARY KEY,

    daily_cost_micros         BIGINT      NOT NULL DEFAULT 2000000,
    daily_question_limit      INTEGER     NOT NULL DEFAULT 200,
    request_latency_budget_ms BIGINT      NOT NULL DEFAULT 25000,

    -- The spend window is a date, and rolling it is derived from the clock
    -- rather than done by a nightly job. A reset task that fails to run leaves
    -- every tenant permanently locked out, and nothing notices until someone
    -- asks a question.
    window_start              DATE        NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')::DATE,
    spent_cost_micros         BIGINT      NOT NULL DEFAULT 0,
    spent_questions           INTEGER     NOT NULL DEFAULT 0,

    updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_advisory_budgets_nonneg CHECK (
        daily_cost_micros >= 0 AND daily_question_limit >= 0 AND
        spent_cost_micros >= 0 AND spent_questions >= 0
    )
);

-- ── Row-level security ──────────────────────────────────────────────────────
--
-- FORCE as well as ENABLE on every table. Without FORCE the policy does not
-- apply to the table's owner, and the service connects as the owner — so
-- ENABLE alone would give a tenant boundary that is off for exactly the role
-- that uses it.

ALTER TABLE advisory_documents     ENABLE ROW LEVEL SECURITY;
ALTER TABLE advisory_documents     FORCE  ROW LEVEL SECURITY;
ALTER TABLE advisory_chunks        ENABLE ROW LEVEL SECURITY;
ALTER TABLE advisory_chunks        FORCE  ROW LEVEL SECURITY;
ALTER TABLE advisory_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE advisory_conversations FORCE  ROW LEVEL SECURITY;
ALTER TABLE advisory_exchanges     ENABLE ROW LEVEL SECURITY;
ALTER TABLE advisory_exchanges     FORCE  ROW LEVEL SECURITY;
ALTER TABLE advisory_budgets       ENABLE ROW LEVEL SECURITY;
ALTER TABLE advisory_budgets       FORCE  ROW LEVEL SECURITY;

CREATE POLICY advisory_documents_tenant_policy ON advisory_documents
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

CREATE POLICY advisory_chunks_tenant_policy ON advisory_chunks
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

CREATE POLICY advisory_conversations_tenant_policy ON advisory_conversations
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

CREATE POLICY advisory_exchanges_tenant_policy ON advisory_exchanges
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));

CREATE POLICY advisory_budgets_tenant_policy ON advisory_budgets
    USING (tenant_id = current_setting('app.tenant_id', true)::CHAR(26))
    WITH CHECK (tenant_id = current_setting('app.tenant_id', true)::CHAR(26));
