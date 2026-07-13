#!/bin/sh
# AirOS CLI installer — one command, full CLI *with AI chat*, on your PATH.
#
#   curl -fsSL https://raw.githubusercontent.com/Manishsv/homebrew-airos/main/install.sh | sh
#
# What it does:
#   1. finds a Python 3.9+
#   2. installs airos + chat deps into an isolated venv (~/.airos/venv)
#   3. symlinks `airos` into a directory already on your PATH
#      (so there's no pipx, no `ensurepath`, no shell reload, one `airos`)
#
# Re-run any time to upgrade. Uninstall:
#   curl -fsSL .../install.sh | sh -s -- --uninstall
set -eu

REPO="Manishsv/homebrew-airos"
SDIST_URL="https://github.com/${REPO}/releases/latest/download/airos.tar.gz"
APP_DIR="${HOME}/.airos"
VENV_DIR="${APP_DIR}/venv"
SPEC="airos[chat] @ ${SDIST_URL}"

info() { printf '  %s\n' "$*"; }
ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$*"; }
die()  { printf '\033[31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# --- uninstall -------------------------------------------------------------
if [ "${1:-}" = "--uninstall" ]; then
  printf '\nUninstalling AirOS CLI...\n'
  for d in /opt/homebrew/bin /usr/local/bin "${HOME}/.local/bin" "${HOME}/bin"; do
    if [ -L "${d}/airos" ]; then
      link=$(readlink "${d}/airos" 2>/dev/null || true)
      case "$link" in "${VENV_DIR}"/*) rm -f "${d}/airos"; ok "removed ${d}/airos" ;; esac
    fi
  done
  rm -rf "${VENV_DIR}" && ok "removed ${VENV_DIR}"
  printf 'Done. (Config/credentials in %s/ were kept.)\n\n' "${APP_DIR}"
  exit 0
fi

printf '\nInstalling the AirOS CLI (with AI chat)...\n\n'

# --- 1. find a Python 3.9+ -------------------------------------------------
PY=""
for c in python3.12 python3.11 python3.10 python3.13 python3 python3.9; do
  command -v "$c" >/dev/null 2>&1 || continue
  v=$("$c" -c 'import sys;print("%d.%d"%sys.version_info[:2])' 2>/dev/null) || continue
  maj=${v%.*}; min=${v#*.}
  if [ "$maj" -eq 3 ] && [ "$min" -ge 9 ]; then PY="$c"; break; fi
done
[ -n "$PY" ] || die "Python 3.9+ not found. Install it (e.g. 'brew install python') and re-run."
ok "using $("$PY" --version 2>&1) ($(command -v "$PY"))"

# --- 2. create/refresh the isolated venv -----------------------------------
mkdir -p "${APP_DIR}"
rm -rf "${VENV_DIR}"
"$PY" -m venv "${VENV_DIR}" || die "could not create a virtualenv at ${VENV_DIR}"
"${VENV_DIR}/bin/python" -m pip install --quiet --upgrade pip >/dev/null 2>&1 || true
info "installing airos + chat dependencies (anthropic/openai/h3 — ~1 min)..."
"${VENV_DIR}/bin/python" -m pip install --quiet "${SPEC}" || die "install failed. Check your network and try again."
ok "installed $("${VENV_DIR}/bin/airos" --version 2>/dev/null || echo 'airos')"

# --- 3. remove conflicting installs (this build supersedes them) -----------
# A separate Homebrew base build or a pipx-installed `airos` would fight for the
# command name / shadow this one, so clear them for a single, unambiguous `airos`.
if command -v brew >/dev/null 2>&1 && brew list --versions airos-cli >/dev/null 2>&1; then
  info "removing the Homebrew base build (this install includes it, plus chat)..."
  brew uninstall airos-cli >/dev/null 2>&1 || true
  ok "removed Homebrew airos-cli"
fi
if command -v pipx >/dev/null 2>&1 && pipx list --short 2>/dev/null | grep -qi '^airos '; then
  info "removing a previous pipx 'airos' (superseded by this install)..."
  pipx uninstall airos >/dev/null 2>&1 || true
  ok "removed pipx airos"
fi

# --- 4. symlink `airos` into a dir already on PATH -------------------------
TARGET=""
for d in /opt/homebrew/bin /usr/local/bin "${HOME}/.local/bin" "${HOME}/bin"; do
  case ":${PATH}:" in *":${d}:"*) ;; *) continue ;; esac   # only dirs on PATH
  if [ -d "$d" ] && [ -w "$d" ]; then TARGET="$d"; break; fi
done
if [ -z "$TARGET" ]; then
  TARGET="${HOME}/.local/bin"; mkdir -p "$TARGET"
  ln -sf "${VENV_DIR}/bin/airos" "${TARGET}/airos"
  rc="${HOME}/.zshrc"; [ -n "${BASH_VERSION:-}" ] && rc="${HOME}/.bashrc"
  printf '\nexport PATH="%s:$PATH"\n' "$TARGET" >> "$rc"
  ok "linked airos -> ${TARGET}/airos"
  warn "added ${TARGET} to PATH in ${rc}"
  warn "open a new terminal (or run: exec \$SHELL) before using 'airos'"
else
  ln -sf "${VENV_DIR}/bin/airos" "${TARGET}/airos"
  ok "linked airos -> ${TARGET}/airos"
fi

printf '\n\033[32mDone!\033[0m  Next:\n\n'
printf '  airos auth login --phone +91XXXXXXXXXX   # or --email you@example.com\n'
printf '  airos auth verify <reference_id> <otp>\n'
printf '  airos chat\n\n'
