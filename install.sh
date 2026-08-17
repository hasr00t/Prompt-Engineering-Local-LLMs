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

echo -e "\n${BOLD}Prompt Engineering Workshop - Lab Installer${RESET}\n"

# --- 0. Don't run as root ---
if [ "$(id -u)" -eq 0 ]; then
    fail "Please run this script as your normal user, not with sudo."
    echo "    The script will use sudo internally for the steps that need it."
    exit 1
fi

# --- 1. Check prerequisites ---
echo -e "${BOLD}[1/5] Checking prerequisites${RESET}"

if ! command -v ollama &>/dev/null; then
    info "Ollama is not installed. Installing now..."
    curl -fsSL https://ollama.com/install.sh | sh
    if ! command -v ollama &>/dev/null; then
        fail "Ollama installation failed."
        echo "    Install it manually: https://ollama.com/download/linux"
        exit 1
    fi
    pass "Ollama installed"
else
    pass "Ollama is installed"
fi

if ! ollama list &>/dev/null; then
    info "Starting Ollama..."
    sudo systemctl start ollama
    sleep 2
    if ! ollama list &>/dev/null; then
        fail "Could not start Ollama."
        echo "    Try manually:  sudo systemctl start ollama"
        exit 1
    fi
    pass "Ollama started"
else
    pass "Ollama is running"
fi

if ! command -v python3 &>/dev/null; then
    fail "Python 3 is not installed."
    echo "    Install it with:  sudo apt install python3"
    exit 1
fi
PY_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
pass "Python 3 is installed ($PY_VERSION)"

info "Installing python3.14-venv (requires sudo)..."
sudo apt-get update -qq > /dev/null 2>&1
sudo apt install -y python3.14-venv > /dev/null 2>&1
if ! python3 -c "import venv" &>/dev/null; then
    fail "Could not install python3.14-venv."
    echo "    Install it manually with:  sudo apt install python3.14-venv"
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
        pass "$MODEL_NAME already exists, skipping"
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
echo -e "${BOLD}To run CLI challenges:${RESET}"
echo "    ollama run injection-level1"
echo ""
echo -e "${BOLD}Starting the Prompt Injection Challenge web app...${RESET}"
echo "    Open http://localhost:5000 in your browser."
echo "    Press Ctrl+C to stop the server."
echo ""
cd "$APP_DIR"
exec "$VENV_DIR/bin/python" app.py
