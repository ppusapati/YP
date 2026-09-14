#!/usr/bin/env bash
#
# Rank the slowest queries and explain the worst of them.
#
# "Which query is slow?" is otherwise answered by guessing. pg_stat_statements
# knows, because it has been counting since the server started; this reads it,
# ranks by total time rather than by mean, and runs EXPLAIN on the top few.
#
# Total time is the right ranking. A query taking 2ms and running a million
# times costs far more than one taking two seconds and running twice, and it is
# the one worth an index — but a report sorted by mean would never show it.
#
# Usage:
#   scripts/slow-queries.sh                 # top 10 from the default database
#   scripts/slow-queries.sh 20              # top 20
#   DATABASE_URL=... scripts/slow-queries.sh
#
# Run it on a replica or off-peak: EXPLAIN is cheap, but the statements it
# explains are the expensive ones by construction.

set -euo pipefail

LIMIT="${1:-10}"
DATABASE_URL="${DATABASE_URL:-postgres://yieldpoint:yieldpoint@localhost:5432/yieldpoint?sslmode=disable}"
EXPLAIN_TOP="${EXPLAIN_TOP:-3}"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required." >&2
  exit 1
fi

run() { psql "$DATABASE_URL" -X -q "$@"; }

if ! run -tAc "SELECT 1" >/dev/null 2>&1; then
  echo "Cannot reach the database at ${DATABASE_URL%%\?*}" >&2
  exit 1
fi

if ! run -tAc "SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements'" | grep -q 1; then
  cat >&2 <<'MSG'
pg_stat_statements is not enabled on this database.

It needs to be preloaded at server start and created once:
  shared_preload_libraries = 'pg_stat_statements'   (docker-compose sets this)
  CREATE EXTENSION pg_stat_statements;
MSG
  exit 1
fi

echo "═══════════════════════════════════════════════════════════════════"
echo " Slowest queries by total time"
echo "═══════════════════════════════════════════════════════════════════"
run <<SQL
\pset format aligned
SELECT
    round(total_exec_time)::bigint      AS total_ms,
    calls,
    round(mean_exec_time::numeric, 2)   AS mean_ms,
    round(stddev_exec_time::numeric, 2) AS stddev_ms,
    rows,
    -- A query whose blocks mostly come from disk is a different problem from
    -- one that is simply called constantly.
    CASE WHEN shared_blks_hit + shared_blks_read = 0 THEN NULL
         ELSE round(100.0 * shared_blks_hit / (shared_blks_hit + shared_blks_read), 1)
    END                                  AS cache_hit_pct,
    left(regexp_replace(query, '\s+', ' ', 'g'), 120) AS query
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY total_exec_time DESC
LIMIT ${LIMIT};
SQL

echo
echo "═══════════════════════════════════════════════════════════════════"
echo " Plans for the top ${EXPLAIN_TOP}"
echo "═══════════════════════════════════════════════════════════════════"
echo

# pg_stat_statements normalises literals to $1, $2 …, which EXPLAIN cannot plan
# without knowing their types. Statements carrying parameters are printed for a
# human to fill in rather than explained wrongly.
mapfile -t QUERIES < <(run -tAc "
  SELECT replace(regexp_replace(query, '\s+', ' ', 'g'), E'\n', ' ')
  FROM pg_stat_statements
  WHERE query NOT LIKE '%pg_stat_statements%'
  ORDER BY total_exec_time DESC
  LIMIT ${EXPLAIN_TOP};")

for q in "${QUERIES[@]}"; do
  [ -z "$q" ] && continue
  echo "── ${q:0:140}"
  if [[ "$q" == *'$1'* ]]; then
    echo "   (parameterised; substitute real values and EXPLAIN by hand)"
    echo
    continue
  fi
  run -c "EXPLAIN (ANALYZE false, BUFFERS false, VERBOSE false) $q" 2>&1 | sed 's/^/   /' || \
    echo "   (could not be planned)"
  echo
done

cat <<'MSG'
Reading these:
  - A sequential scan over a large table in a hot query usually wants an index.
  - Rows removed by a filter far exceeding rows returned means the index that
    exists is not the one the query needs.
  - A low cache hit rate on a frequent query is a memory problem, not a plan
    problem, and adding an index will not fix it.

Reset the counters after acting on them, so the next report measures the change:
  SELECT pg_stat_statements_reset();
MSG
