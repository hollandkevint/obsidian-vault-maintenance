#!/bin/bash
# Daily Vault Maintenance - Automation Wrapper
# Runs Claude Code with maintenance prompt for headless execution
#
# Usage:
#   ./daily-vault-maintenance.sh                    # Auto-detect auth
#   ./daily-vault-maintenance.sh --oauth            # Force OAuth (Max plan)
#   ./daily-vault-maintenance.sh --api              # Force API key
#   ./daily-vault-maintenance.sh /path/to/vault     # Specify vault path
#
# Authentication priority:
#   1. OAuth token from macOS Keychain (claude-code-oauth)
#   2. OAuth token from vault .env (CLAUDE_CODE_OAUTH_TOKEN)
#   3. API key from environment (ANTHROPIC_API_KEY)
#
# Setup:
#   1. Generate OAuth token: claude setup-token
#   2. Store in Keychain: security add-generic-password -a "$USER" -s "claude-code-oauth" -w "TOKEN"
#   3. Or add to vault .env: echo 'CLAUDE_CODE_OAUTH_TOKEN=TOKEN' >> .env

set -e

# ============================================
# CONFIGURATION - Edit these for your setup
# ============================================

# Default vault path (override with argument)
VAULT_PATH="${VAULT_PATH:-$HOME/Documents/Obsidian Vault}"

# Prompt file location
PROMPT_FILE="${PROMPT_FILE:-$HOME/.claude/prompts/daily-vault-maintenance.md}"

# Log directory
LOG_DIR="${LOG_DIR:-$HOME/.claude/logs}"

# Claude CLI path (adjust if installed elsewhere)
CLAUDE_BIN="${CLAUDE_BIN:-$(which claude 2>/dev/null || echo "$HOME/.local/bin/claude")}"

# ============================================
# ARGUMENT PARSING
# ============================================

AUTH_MODE="auto"
while [[ $# -gt 0 ]]; do
    case $1 in
        --oauth) AUTH_MODE="oauth"; shift ;;
        --api) AUTH_MODE="api"; shift ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS] [VAULT_PATH]"
            echo ""
            echo "Options:"
            echo "  --oauth    Force OAuth token authentication (Max plan)"
            echo "  --api      Force API key authentication (pay-per-use)"
            echo "  --help     Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  VAULT_PATH              Path to Obsidian vault"
            echo "  PROMPT_FILE             Path to maintenance prompt"
            echo "  CLAUDE_CODE_OAUTH_TOKEN OAuth token (if not in Keychain)"
            echo "  ANTHROPIC_API_KEY       API key (for --api mode)"
            exit 0
            ;;
        *)
            if [[ -d "$1" ]]; then
                VAULT_PATH="$1"
            fi
            shift
            ;;
    esac
done

# ============================================
# AUTHENTICATION SETUP
# ============================================

setup_auth() {
    if [[ "$AUTH_MODE" == "api" ]]; then
        unset CLAUDE_CODE_OAUTH_TOKEN
        if [ -z "$ANTHROPIC_API_KEY" ]; then
            echo "ERROR: --api specified but ANTHROPIC_API_KEY not set"
            exit 1
        fi
        echo "Auth: Using API key (pay-per-use)"
        return
    fi

    # Try macOS Keychain first
    if command -v security &> /dev/null; then
        OAUTH_TOKEN=$(security find-generic-password -a "$USER" -s "claude-code-oauth" -w 2>/dev/null || true)
        if [ -n "$OAUTH_TOKEN" ]; then
            export CLAUDE_CODE_OAUTH_TOKEN="$OAUTH_TOKEN"
            unset ANTHROPIC_API_KEY
            echo "Auth: Using OAuth token from Keychain (Max plan)"
            return
        fi
    fi

    # Try vault .env file
    if [ -f "$VAULT_PATH/.env" ]; then
        source "$VAULT_PATH/.env"
        if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
            unset ANTHROPIC_API_KEY
            echo "Auth: Using OAuth token from .env (Max plan)"
            return
        fi
    fi

    # Fall back to API key (unless forcing OAuth)
    if [[ "$AUTH_MODE" != "oauth" ]] && [ -n "$ANTHROPIC_API_KEY" ]; then
        unset CLAUDE_CODE_OAUTH_TOKEN
        echo "Auth: Using API key (pay-per-use) - OAuth unavailable"
        return
    fi

    echo "ERROR: No authentication available"
    echo ""
    echo "To fix, choose one:"
    echo "  1. Run 'claude setup-token' and store in Keychain:"
    echo "     security add-generic-password -a \"\$USER\" -s \"claude-code-oauth\" -w \"TOKEN\""
    echo ""
    echo "  2. Add to vault .env:"
    echo "     echo 'CLAUDE_CODE_OAUTH_TOKEN=TOKEN' >> \"$VAULT_PATH/.env\""
    echo ""
    echo "  3. Set API key:"
    echo "     export ANTHROPIC_API_KEY=your_key"
    exit 1
}

# ============================================
# VALIDATION
# ============================================

if [ ! -d "$VAULT_PATH" ]; then
    echo "ERROR: Vault not found at: $VAULT_PATH"
    echo "Set VAULT_PATH or pass as argument"
    exit 1
fi

if [ ! -f "$PROMPT_FILE" ]; then
    echo "ERROR: Prompt file not found at: $PROMPT_FILE"
    echo "Copy prompts/daily-vault-maintenance.md to ~/.claude/prompts/"
    exit 1
fi

if [ ! -x "$CLAUDE_BIN" ] && [ ! -f "$CLAUDE_BIN" ]; then
    echo "ERROR: Claude CLI not found"
    echo "Install from: https://claude.ai/code"
    exit 1
fi

# ============================================
# EXECUTION
# ============================================

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "$LOG_DIR"

echo "=========================================="
echo "Vault Maintenance Started: $TIMESTAMP"
echo "Vault: $VAULT_PATH"
echo "=========================================="

setup_auth

cd "$VAULT_PATH"

# Run Claude Code with maintenance prompt
"$CLAUDE_BIN" \
    --print \
    --dangerously-skip-permissions \
    --max-turns 50 \
    < "$PROMPT_FILE"

echo ""
echo "=========================================="
echo "Vault Maintenance Completed: $(date +"%Y-%m-%d_%H-%M-%S")"
echo "=========================================="
