#!/usr/bin/env bash
set -euo pipefail

echo "Scanning for broad except patterns (except: | except Exception)"

grep -nR --line-number --exclude-dir={.git,.venv,build,dist} -E "^\s*except(\s+Exception|\s*:)" . || true
