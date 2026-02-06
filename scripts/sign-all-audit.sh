#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

AUDIT_DIR=".audit"
if [[ ! -d "$AUDIT_DIR" ]]; then
  echo "No audit directory found; nothing to sign."
  exit 0
fi

# Collect files robustly (avoid globbing issues)
readarray -t files < <(find "$AUDIT_DIR" -maxdepth 1 -type f -name '*.json' -print)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "No audit JSON files to sign."
  exit 0
fi

if ! command -v gpg >/dev/null 2>&1; then
  echo "gpg not found on PATH; cannot sign audit files."
  exit 1
fi

for f in "${files[@]}"; do
  sig="${f}.asc"
  if [[ -f "$sig" ]]; then
    echo "Already signed: $(basename "$f")"
    continue
  fi
  echo "Signing: $(basename "$f")"
  if gpg --armor --detach-sign --output "$sig" "$f"; then
    echo "Signed: $(basename "$f") -> $(basename "$sig")"
  else
    echo "Failed to sign: $(basename "$f")" >&2
  fi
done
