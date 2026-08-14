#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODELFILES_DIR="$SCRIPT_DIR/lab files/modelfiles"
APP_DIR="$SCRIPT_DIR/lab files/injection-app"
VENV_DIR="$APP_DIR/.venv"

# --- Colors (degrade gracefully without TTY) ---
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' RED='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

pass() { echo -e "  ${GREEN}✔${RESET} $1"; }
fail() { echo -e "  ${RED}✘${RESET} $1"; }
info() { echo -e "  ${BLUE}→${RESET} $1"; }
warn() { echo -e "  ${YELLOW}!${RESET} $1"; }

echo -e "\n${BOLD}Prompt Engineering Workshop — Lab Installer${RESET}\n"

# --- 1. Check prerequisites ---
echo -e "${BOLD}[1/5] Checking prerequisites${RESET}"

if ! command -v ollama &>/dev/null; then
    fail "Ollama is not installed."
    echo "    Install it first — this should have been done in the Keeping Things Local workshop."
    echo "    https://ollama.com/download/linux"
    exit 1
fi
pass "Ollama is installed"

if ! ollama list &>/dev/null; then
    fail "Ollama is not running."
    echo "    Start it with:  sudo systemctl start ollama"
    exit 1
fi
pass "Ollama is running"

if ! command -v python3 &>/dev/null; then
    fail "Python 3 is not installed."
    echo "    Install it with:  sudo apt install python3 python3-venv"
    exit 1
fi
pass "Python 3 is installed ($(python3 --version 2>&1 | awk '{print $2}'))"

if ! python3 -c "import venv" &>/dev/null; then
    fail "Python venv module is not available."
    echo "    Install it with:  sudo apt install python3-venv"
    exit 1
fi
pass "Python venv module is available"

# --- 2. Pull llama3.2 ---
echo -e "\n${BOLD}[2/5] Checking llama3.2 model${RESET}"

if ollama list | grep -q "llama3.2"; then
    pass "llama3.2 is already pulled"
else
    info "Pulling llama3.2 (this may take a few minutes)..."
    ollama pull llama3.2
    pass "llama3.2 pulled"
fi

# --- 3. Build injection models ---
echo -e "\n${BOLD}[3/5] Building injection challenge models${RESET}"

for i in 1 2 3 4 5 6; do
    MODEL_NAME="injection-level${i}"
    MODELFILE="$MODELFILES_DIR/Modelfile.injection-${i}"

    if [ ! -f "$MODELFILE" ]; then
        fail "Modelfile not found: $MODELFILE"
        exit 1
    fi

    if ollama list | grep -q "$MODEL_NAME"; then
        pass "$MODEL_NAME already exists — skipping"
    else
        info "Building $MODEL_NAME..."
        ollama create "$MODEL_NAME" -f "$MODELFILE"
        pass "$MODEL_NAME built"
    fi
done

# --- 4. Set up Python virtual environment ---
echo -e "\n${BOLD}[4/5] Setting up injection app${RESET}"

if [ -d "$VENV_DIR" ] && [ -f "$VENV_DIR/bin/activate" ]; then
    pass "Virtual environment already exists"
else
    info "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    pass "Virtual environment created"
fi

info "Installing Python dependencies..."
"$VENV_DIR/bin/pip" install --quiet --upgrade pip
"$VENV_DIR/bin/pip" install --quiet -r "$APP_DIR/requirements.txt"
pass "Dependencies installed (flask, requests)"

# --- 5. Smoke test ---
echo -e "\n${BOLD}[5/5] Smoke test${RESET}"

MODELS_FOUND=$(ollama list | grep -c "injection-level" || true)
if [ "$MODELS_FOUND" -eq 6 ]; then
    pass "All 6 injection models are loaded"
else
    warn "Expected 6 injection models, found $MODELS_FOUND"
fi

if "$VENV_DIR/bin/python" -c "import flask; import requests" &>/dev/null; then
    pass "Flask and requests import successfully"
else
    fail "Python dependencies failed to import"
    exit 1
fi

# --- Done ---
echo -e "\n${GREEN}${BOLD}Setup complete!${RESET}\n"
echo -e "${BOLD}To run the labs:${RESET}"
echo ""
echo "  CLI challenges (any level):"
echo "    ollama run injection-level1"
echo ""
echo "  Web app (recommended for the injection lab):"
echo "    cd \"$APP_DIR\""
echo "    source .venv/bin/activate"
echo "    python3 app.py"
echo "    # Then open http://localhost:5000"
echo ""
