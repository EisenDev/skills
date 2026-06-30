#!/usr/bin/env bash

# logger.sh - Colorful logging library with elapsed execution time tracking

# ANSI Escape Codes for Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Check if stdout is a terminal
if [ ! -t 1 ]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    NC=''
fi

# Track system start timestamp
START_TIME=$(date +%s)

# Calculate elapsed execution time
get_elapsed_time() {
    local now
    now=$(date +%s)
    local elapsed=$((now - START_TIME))
    echo "[${elapsed}s]"
}

log_info() {
    printf "${CYAN}ℹ Info${NC} %s %s\n" "$(get_elapsed_time)" "$*"
}

log_success() {
    printf "${GREEN}✓ Success${NC} %s %s\n" "$(get_elapsed_time)" "$*"
}

log_installed() {
    printf "${GREEN}✓ Installed${NC} %s %s\n" "$(get_elapsed_time)" "$*"
}

log_updated() {
    printf "${GREEN}✓ Updated${NC} %s %s\n" "$(get_elapsed_time)" "$*"
}

log_warn() {
    printf "${YELLOW}⚠ Warning${NC} %s %s\n" "$(get_elapsed_time)" "$*"
}

log_error() {
    printf "${RED}✗ Error${NC} %s %s\n" "$(get_elapsed_time)" "$*" >&2
}

log_bold() {
    printf "${BOLD}%s${NC}\n" "$*"
}
