#!/bin/bash

FLUTTER=/home/codespace/flutter/bin/flutter
ROOT="$(cd "$(dirname "$0")" && pwd)"

# Controlla dipendenze e installa se mancanti
DEPS_OK=true
python3 -c "import flask, flask_cors" 2>/dev/null || DEPS_OK=false
[ -d "$ROOT/staff/node_modules" ] || DEPS_OK=false
[ -d "$ROOT/totem/.dart_tool" ] || DEPS_OK=false

if [ "$DEPS_OK" = false ]; then
    echo "Dipendenze mancanti - eseguo install.sh..."
    bash "$ROOT/install.sh" || { echo "Installazione fallita. Uscita."; exit 1; }
fi

echo "=== Avvio Backend Flask (porta 5000) ==="
cd "$ROOT/backend"
python3 app.py &
BACKEND_PID=$!

echo "=== Avvio Staff Angular (porta 4200) ==="
cd "$ROOT/staff"
npm start &
STAFF_PID=$!

echo "=== Avvio Totem Flutter (web, porta 8080) ==="
cd "$ROOT/totem"
$FLUTTER run -d web-server --web-port 8080 &
TOTEM_PID=$!

echo ""
echo "Tutti avviati. PID: backend=$BACKEND_PID  staff=$STAFF_PID  totem=$TOTEM_PID"
echo "Premi Ctrl+C per fermare tutto."

trap "echo 'Arresto...'; kill $BACKEND_PID $STAFF_PID $TOTEM_PID 2>/dev/null" SIGINT SIGTERM
wait
