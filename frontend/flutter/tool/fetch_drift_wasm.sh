#!/usr/bin/env bash
# Fetch the sqlite3 WASM module + drift_worker.js into web/ for
# `flutter run -d chrome` and `flutter build web`.
#
# Two upstream sources:
# - `drift_worker.js` is published per-release on
#   https://github.com/simolus3/drift (tag `drift-X.Y.Z`).
# - `sqlite3.wasm` is published on
#   https://github.com/simolus3/sqlite3.dart (tag `sqlite3-X.Y.Z`).
#   Its X.Y.Z is the sqlite3 C library version, NOT the Dart
#   package version — pin a known-good build here.
#
# CI does the same thing inline in .github/workflows/deploy-web.yml.
set -euo pipefail

cd "$(dirname "$0")/.."

DRIFT_VERSION=$(awk '/^  drift:$/{f=1;next} f && /version:/{gsub(/[" ]/,"",$2); print $2; exit}' pubspec.lock)
if [[ -z "$DRIFT_VERSION" ]]; then
  echo "Could not resolve drift version from pubspec.lock" >&2
  exit 1
fi

# Pinned sqlite3 WASM build. Bump when drift's WASM ABI changes
# (i.e. if the next `drift_worker.js` version refuses to load this
# WASM, pick a newer sqlite3-X.Y.Z release).
SQLITE3_WASM_TAG="${SQLITE3_WASM_TAG:-sqlite3-3.3.1}"

echo "Resolved drift version    : $DRIFT_VERSION"
echo "Pinned sqlite3 WASM tag   : $SQLITE3_WASM_TAG"

mkdir -p web
curl --fail --location --silent --show-error \
  -o web/sqlite3.wasm \
  "https://github.com/simolus3/sqlite3.dart/releases/download/${SQLITE3_WASM_TAG}/sqlite3.wasm"
curl --fail --location --silent --show-error \
  -o web/drift_worker.js \
  "https://github.com/simolus3/drift/releases/download/drift-${DRIFT_VERSION}/drift_worker.js"

echo "Downloaded:"
ls -l web/sqlite3.wasm web/drift_worker.js
