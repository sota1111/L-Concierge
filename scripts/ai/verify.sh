#!/usr/bin/env bash
set -euo pipefail

echo "== environment =="
whoami
pwd
node --version || true
npm --version || true

echo "== install =="
if [ -f package-lock.json ]; then
  npm ci
elif [ -f package.json ]; then
  npm install
fi

echo "== lint =="
npm run lint || true

echo "== typecheck =="
npm run typecheck || true

echo "== test =="
npm test || true

echo "== e2e =="
npm run e2e || true
