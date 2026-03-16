#!/bin/sh
# Token Spy multi-agent launcher
# Starts per-service monitoring instances alongside the main instance.
# All processes share the same SQLite database, so one dashboard shows
# all agents. Each process gets its own AGENT_NAME and port.
#
# Only starts monitoring instances when TOKEN_SPY_AUTH_MODE=local
# (i.e., when local monitoring is enabled in .env).

set -e

# Main instance — always starts (cloud/agent monitoring, dashboard)
AGENT_NAME="${AGENT_NAME:-token-spy}" \
  uvicorn main:app --host 0.0.0.0 --port 8080 --log-level info &

# Per-service monitoring instances — only when local monitoring is enabled
if [ "${AUTH_MODE}" = "local" ]; then
  echo "[token-spy] Local monitoring enabled — starting per-service instances"

  AUTH_MODE=local AGENT_NAME=open-webui \
    uvicorn main:app --host 0.0.0.0 --port 8081 --log-level warning &

  AUTH_MODE=local AGENT_NAME=perplexica \
    uvicorn main:app --host 0.0.0.0 --port 8082 --log-level warning &

  AUTH_MODE=local AGENT_NAME=openclaw \
    uvicorn main:app --host 0.0.0.0 --port 8083 --log-level warning &

  AUTH_MODE=local AGENT_NAME=litellm \
    uvicorn main:app --host 0.0.0.0 --port 8084 --log-level warning &

  AUTH_MODE=local AGENT_NAME=n8n \
    uvicorn main:app --host 0.0.0.0 --port 8085 --log-level warning &

  echo "[token-spy] Per-service instances: open-webui(:8081) perplexica(:8082) openclaw(:8083) litellm(:8084) n8n(:8085)"
else
  echo "[token-spy] Local monitoring disabled — main instance only"
fi

# Wait for any process to exit
wait
