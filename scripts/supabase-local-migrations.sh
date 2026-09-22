#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_RUNNER="$ROOT_DIR/scripts/apply-and-test-supabase-local.sql"
MODE="${1:-reset}"

usage() {
  cat <<'USAGE'
Usage: scripts/supabase-local-migrations.sh [reset|apply|check]

  reset  Start Supabase if needed, reset the local database, then run checks.
  apply  Apply all migrations to a blank PostgreSQL database using DATABASE_URL.
  check  Run assertions only against an already migrated database.

Environment:
  DATABASE_URL  PostgreSQL URL used by `apply` or as an override for `check`.
USAGE
}

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

case "$MODE" in
  reset|apply|check) ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

[[ -f "$SQL_RUNNER" ]] || fail "SQL runner not found: $SQL_RUNNER"

if [[ "$MODE" == "reset" ]]; then
  command -v supabase >/dev/null 2>&1 || fail "supabase CLI is required for reset"
  supabase start
  supabase db reset
fi

if [[ -n "${DATABASE_URL:-}" ]]; then
  DB_URL="$DATABASE_URL"
elif command -v supabase >/dev/null 2>&1; then
  DB_URL="$(supabase status -o env 2>/dev/null | awk -F= '$1 == "DB_URL" {sub(/^\"|\"$/, "", $2); print $2; exit}')"
else
  DB_URL=""
fi

[[ -n "$DB_URL" ]] || fail "DATABASE_URL is required unless a running Supabase CLI can provide DB_URL"
command -v psql >/dev/null 2>&1 || fail "psql is required to execute the SQL runner"

PSQL_ARGS=("$DB_URL" -v ON_ERROR_STOP=1 -f "$SQL_RUNNER")
if [[ "$MODE" == "apply" ]]; then
  psql "${PSQL_ARGS[@]}" -v APPLY_MIGRATIONS=1
else
  psql "${PSQL_ARGS[@]}"
fi

echo "Supabase local migrations: $MODE completed successfully."
