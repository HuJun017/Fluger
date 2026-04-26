#!/bin/bash

FLUTTER=/home/codespace/flutter/bin/flutter
ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "=== Installazione dipendenze Fluger ==="

echo ""
echo "[1/3] Backend Python..."
pip install -r "$ROOT/backend/requirements.txt" || { echo "ERRORE: pip install fallito."; exit 1; }

echo ""
echo "[2/3] Staff Angular..."
cd "$ROOT/staff" && npm install || { echo "ERRORE: npm install fallito."; exit 1; }

echo ""
echo "[3/3] Totem Flutter..."
cd "$ROOT/totem" && $FLUTTER pub get || { echo "ERRORE: flutter pub get fallito."; exit 1; }

echo ""
echo "=== Dipendenze installate correttamente ==="
