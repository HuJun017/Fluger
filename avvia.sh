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

# Libera le porte prima di avviare (evita conflitti da sessioni precedenti)
fuser -k 5000/tcp 4200/tcp 8080/tcp 2>/dev/null && sleep 1

# Auto-rileva URL backend (Codespaces o locale)
if [ -n "$CODESPACE_NAME" ] && [ -n "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
    BACKEND_URL="https://${CODESPACE_NAME}-5000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
else
    BACKEND_URL="http://localhost:5000"
fi
echo "Backend URL: $BACKEND_URL"
printf '{"backendUrl":"%s"}' "$BACKEND_URL" > "$ROOT/totem/assets/config.json"

# Trap definito prima dell'avvio così è attivo da subito
cleanup() {
  echo 'Arresto...'
  for pid in $BACKEND_PID $STAFF_PID $TOTEM_PID; do
    pkill -P "$pid" 2>/dev/null
    kill "$pid" 2>/dev/null
  done
  fuser -k 5000/tcp 4200/tcp 8080/tcp 2>/dev/null
}
trap cleanup SIGINT SIGTERM

echo "=== Avvio Backend Flask (porta 5000) ==="
(cd "$ROOT/backend" && python3 app.py) &
BACKEND_PID=$!

echo "=== Avvio Staff Angular (porta 4200) ==="
(cd "$ROOT/staff" && CI=1 NG_CLI_ANALYTICS=false npm start) &
STAFF_PID=$!

echo "=== Avvio Totem Flutter (web, porta 8080) ==="
(cd "$ROOT/totem" && "$FLUTTER" run -d web-server --web-port 8080) &
TOTEM_PID=$!

echo ""
echo "Tutti avviati. PID: backend=$BACKEND_PID  staff=$STAFF_PID  totem=$TOTEM_PID"
echo "Premi Ctrl+C per fermare tutto."

wait
