#!/usr/bin/env bash
# Reads .env and runs the app with the matching --dart-define flags, so you
# don't have to retype them by hand every time. This does NOT change how the
# app reads config (still --dart-define, still String.fromEnvironment in
# lib/services/supabase_config.dart) — it just automates copying the values
# out of .env for you. GEMINI_API_KEY is deliberately never read here; it
# never belongs on this command (see .env.example for why).
#
# Usage: ./run.sh            (defaults to chrome)
#        ./run.sh web-server (or any other flutter run -d target)

set -euo pipefail

if [ ! -f .env ]; then
  echo "No .env found. Run: cp .env.example .env, then fill in your real values."
  exit 1
fi

# Load SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY from .env into this shell.
set -a
# shellcheck disable=SC1091
source .env
set +a

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_PUBLISHABLE_KEY:-}" ]; then
  echo "SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY is empty in .env — fill both in first."
  exit 1
fi

TARGET="${1:-chrome}"

flutter run -d "$TARGET" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY"
