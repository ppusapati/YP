-- Build the approximate-nearest-neighbour index on the advisory corpus.
--
-- Run this once a real corpus exists, not at migration time.
--
-- ivfflat partitions the vector space by clustering the rows that are already
-- there. Built on an empty table it produces a single list, and every query
-- afterwards scans the whole table while the plan says "Index Scan" — which is
-- the worst of both worlds: no speed-up and no sign that anything is wrong.
-- The initial migration therefore creates no vector index at all, and an exact
-- scan over a few thousand chunks is milliseconds.
--
-- Rule of thumb for `lists`: rows/1000 up to a million rows, then sqrt(rows).
-- Below a few thousand chunks the index is not worth building; measure first.
--
--   psql "$ADVISORY_SERVICE_DATABASE_URL" -f build-vector-index.sql
--
-- CONCURRENTLY so the build does not take a write lock on a live table. It
-- cannot run inside a transaction block, which is the other reason this is not
-- a migration.

-- Cosine distance, matching the `<=>` operator the search query uses. An index
-- built for a different operator class is simply never used, silently.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_advisory_chunks_embedding
    ON advisory_chunks
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

ANALYZE advisory_chunks;

-- Check that it is actually used, rather than assuming:
--
--   SET ivfflat.probes = 10;
--   EXPLAIN ANALYZE
--   SELECT id FROM advisory_chunks
--   WHERE tenant_id = '<a real tenant>'
--   ORDER BY embedding <=> '[...]'::vector
--   LIMIT 24;
--
-- `ivfflat.probes` trades recall for speed and defaults to 1, which on a
-- hundred lists reads roughly a hundredth of the corpus and misses passages it
-- should have found. Ten is a reasonable starting point.
