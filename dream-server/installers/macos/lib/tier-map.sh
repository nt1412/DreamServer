#!/bin/bash
# ============================================================================
# Dream Server macOS Installer -- Tier Map
# ============================================================================
# Part of: installers/macos/lib/
# Purpose: Map hardware tier to model name, GGUF file, URL, and context size
#
# Canonical source: installers/lib/tier-map.sh (keep values byte-identical)
#
# Modder notes:
#   Add new tiers or change model assignments here.
#   Each tier maps to a specific GGUF quantization and context window.
#
#   Apple Silicon unified memory advantage:
#   All system RAM is available as "VRAM." An M2 Max with 64GB RAM can
#   load models that would need a 64GB discrete GPU on other platforms.
#   Tier mapping is based on total system RAM.
# ============================================================================

resolve_tier_config() {
    local tier="$1"

    case "$tier" in
        CLOUD)
            TIER_NAME="Cloud (API)"
            LLM_MODEL="anthropic/claude-sonnet-4-5-20250514"
            GGUF_FILE=""
            GGUF_URL=""
            GGUF_SHA256=""
            MAX_CONTEXT=200000
            ;;
        4)
            TIER_NAME="Enterprise"
            LLM_MODEL="qwen3-30b-a3b"
            GGUF_FILE="Qwen3-30B-A3B-Q4_K_M.gguf"
            GGUF_URL="https://huggingface.co/unsloth/Qwen3-30B-A3B-GGUF/resolve/main/Qwen3-30B-A3B-Q4_K_M.gguf"
            GGUF_SHA256="9f1a24700a339b09c06009b729b5c809e0b64c213b8af5b711b3dbdfd0c5ba48"
            MAX_CONTEXT=131072
            ;;
        3)
            TIER_NAME="Pro"
            LLM_MODEL="qwen3-30b-a3b"
            GGUF_FILE="Qwen3-30B-A3B-Q4_K_M.gguf"
            GGUF_URL="https://huggingface.co/unsloth/Qwen3-30B-A3B-GGUF/resolve/main/Qwen3-30B-A3B-Q4_K_M.gguf"
            GGUF_SHA256="9f1a24700a339b09c06009b729b5c809e0b64c213b8af5b711b3dbdfd0c5ba48"
            MAX_CONTEXT=32768
            ;;
        2)
            TIER_NAME="Prosumer"
            LLM_MODEL="qwen3-8b"
            GGUF_FILE="Qwen3-8B-Q4_K_M.gguf"
            GGUF_URL="https://huggingface.co/unsloth/Qwen3-8B-GGUF/resolve/main/Qwen3-8B-Q4_K_M.gguf"
            GGUF_SHA256="120307ba529eb2439d6c430d94104dabd578497bc7bfe7e322b5d9933b449bd4"
            MAX_CONTEXT=32768
            ;;
        1)
            TIER_NAME="Entry Level"
            LLM_MODEL="qwen3-8b"
            GGUF_FILE="Qwen3-8B-Q4_K_M.gguf"
            GGUF_URL="https://huggingface.co/unsloth/Qwen3-8B-GGUF/resolve/main/Qwen3-8B-Q4_K_M.gguf"
            GGUF_SHA256="120307ba529eb2439d6c430d94104dabd578497bc7bfe7e322b5d9933b449bd4"
            MAX_CONTEXT=16384
            ;;
        *)
            ai_err "Invalid tier: $tier. Valid tiers: 1, 2, 3, 4, CLOUD"
            exit 1
            ;;
    esac
}

# Auto-select tier based on Apple Silicon chip and RAM
# Apple Silicon unified memory: all system RAM = effective VRAM
auto_select_tier() {
    local ram_gb="$1"
    local chip_variant="${2:-base}"

    # Ultra chips (M1/M2/M3/M4 Ultra) with 64GB+ → Tier 4
    if [[ "$chip_variant" == "Ultra" ]] && [[ "$ram_gb" -ge 64 ]]; then
        echo "4"
        return
    fi

    # Max chips with 32GB+ → Tier 3
    if [[ "$chip_variant" == "Max" ]] && [[ "$ram_gb" -ge 32 ]]; then
        echo "3"
        return
    fi

    # Pro chips with 16-32GB → Tier 2
    if [[ "$chip_variant" == "Pro" ]] && [[ "$ram_gb" -ge 16 ]]; then
        echo "2"
        return
    fi

    # RAM-based fallback for any variant
    if [[ "$ram_gb" -ge 64 ]]; then
        echo "4"
    elif [[ "$ram_gb" -ge 32 ]]; then
        echo "3"
    elif [[ "$ram_gb" -ge 16 ]]; then
        echo "2"
    else
        echo "1"
    fi
}
