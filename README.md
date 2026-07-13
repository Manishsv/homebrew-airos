# homebrew-airos

Homebrew tap for the **AirOS CLI** — a data explorer and AI chat client for the
AirOS Sustainable Cities platform (AI CoE, IIT Kanpur).

## Install

### Recommended — one command (full CLI, includes AI chat)

```bash
curl -fsSL https://raw.githubusercontent.com/Manishsv/homebrew-airos/main/install.sh | sh
```

Installs the complete CLI **including `airos chat`**, puts `airos` on your PATH,
and needs no access to the private repo. Re-run any time to upgrade; uninstall
with `curl -fsSL .../install.sh | sh -s -- --uninstall`.

### Alternative — Homebrew (data explorer only, no chat)

```bash
brew tap manishsv/airos
brew install airos-cli
```

Lighter and familiar, but **without** `airos chat` (its AI dependencies can't
build in Homebrew's sandbox). Use the one-liner above if you want chat.

Either way, `airos` talks to the hosted AirOS deployment through the Kong
gateway out of the box — no configuration required. Check it:

```bash
airos ping
```

## Authentication

AirOS uses phone/email + OTP login. New accounts require admin approval before
full access.

```bash
# 1. Register (first time) — sends an OTP and returns a reference ID
airos auth register --phone +919876543210 --name "Your Name"
#   or:  airos auth register --email you@example.com --name "Your Name"

# 2. Verify the OTP to finish (omit the reference ID to reuse the saved one)
airos auth verify <reference_id> <otp_code>

# Returning users: login sends a fresh OTP, then verify the same way
airos auth login --phone +919876543210
airos auth verify <reference_id> <otp_code>
```

Other auth commands:

```bash
airos auth status      # login + approval status (roles, token expiry)
airos auth whoami      # current identity
airos auth resend-otp  # resend a pending OTP
airos auth logout      # clear saved credentials
```

**Account approval:** after verifying, your account is `PENDING_APPROVAL` until
an administrator approves it (via `airos admin`). Check with `airos auth status`.
Pilot/demo deployments may accept a fixed OTP for testing — ask your
administrator.

## Use it

```bash
airos ls schemas               # list all data schemas
airos describe air.advisory    # schema fields + sample data
airos query cell.demographics  # query records from a schema
airos cell <h3_index>          # everything for one H3 cell
airos stats                    # registry statistics
airos export cell.roads roads.csv
```

Run `airos --help` for the full command set.

## `airos chat` (AI chat)

The Homebrew build is data-explorer only — `airos chat` isn't included (its AI
dependencies can't build in Homebrew's sandbox). To get chat, use the one-line
installer at the top of this page:

```bash
curl -fsSL https://raw.githubusercontent.com/Manishsv/homebrew-airos/main/install.sh | sh
```

It installs the full CLI (base + chat) into an isolated venv, puts `airos` on
your PATH, and removes the Homebrew base build so you end up with a single
`airos` that does everything. Then `airos chat` just works.

## Upgrading

- **Installed via the one-liner:** re-run it — `curl -fsSL …/install.sh | sh`.
- **Installed via Homebrew (base only):** `brew update && brew upgrade airos-cli`.

## For maintainers

The formula in `Formula/airos-cli.rb` is generated and published from the AirOS
repo via `cli/packaging/homebrew/publish.sh`. The CLI sdist for each release is
attached to a `cli-vX.Y.Z` GitHub release **on this public tap repo** (the AirOS
source repo is private, so `brew install` — which fetches unauthenticated — must
pull the tarball from a public host).
