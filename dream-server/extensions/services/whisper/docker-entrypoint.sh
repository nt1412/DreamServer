#!/bin/sh
# ============================================================================
# DreamServer Whisper VAD Patch
# ============================================================================
# Injects Voice Activity Detection parameters into the speaches STT router.
# This runs at container startup and is IDEMPOTENT — safe across restarts.
#
# Why: The upstream speaches image doesn't include VAD tuning parameters
# that work well for conversational AI. This patch adds them at runtime
# so we don't need to maintain a custom Docker image.
#
# The DREAM_PATCHED marker prevents duplicate insertion when Docker
# restarts the container (which preserves the writable filesystem layer).
# ============================================================================

STT_FILE="/home/ubuntu/speaches/src/speaches/routers/stt.py"

apply_patch() {
    # Already patched? Skip to prevent duplicate insertion on restart
    if grep -q "DREAM_PATCHED" "$STT_FILE" 2>/dev/null; then
        echo "[dream-whisper] VAD patch already applied, skipping"
        return 0
    fi

    # Check if target pattern exists
    if ! grep -qE '^[[:space:]]*vad_filter[[:space:]]*=[[:space:]]*effective_vad_filter[[:space:]]*,?[[:space:]]*$' "$STT_FILE" 2>/dev/null; then
        echo "[dream-whisper] WARNING: Target pattern not found in $STT_FILE" >&2
        echo "[dream-whisper] Upstream may have changed - patch skipped" >&2
        return 0
    fi

    # Apply patch - match the FULL LINE to prevent partial matches
    # Replaces the vad_filter line with vad_filter + vad_parameters + marker
    if command -v perl >/dev/null 2>&1; then
        perl -i -pe 's/^[[:space:]]*vad_filter\s*=\s*effective_vad_filter\s*,?\s*$/            vad_filter=effective_vad_filter,\n            vad_parameters={"threshold": 0.3, "min_silence_duration_ms": 400, "min_speech_duration_ms": 50, "speech_pad_ms": 200},  # DREAM_PATCHED/' "$STT_FILE"
    else
        sed -i -E '/^[[:space:]]*vad_filter[[:space:]]*=[[:space:]]*effective_vad_filter[[:space:]]*,?[[:space:]]*$/c\            vad_filter=effective_vad_filter,\n            vad_parameters={"threshold": 0.3, "min_silence_duration_ms": 400, "min_speech_duration_ms": 50, "speech_pad_ms": 200},  # DREAM_PATCHED' "$STT_FILE"
    fi

    # Verify
    if grep -q "DREAM_PATCHED" "$STT_FILE" 2>/dev/null; then
        echo "[dream-whisper] VAD patch applied successfully"
    else
        echo "[dream-whisper] WARNING: Patch verification failed" >&2
    fi
}

# Apply patch if file exists and is writable (non-fatal if it fails)
if [ -f "$STT_FILE" ] && [ -w "$STT_FILE" ]; then
    apply_patch
elif [ ! -f "$STT_FILE" ]; then
    echo "[dream-whisper] WARNING: $STT_FILE not found, skipping patch" >&2
else
    echo "[dream-whisper] WARNING: $STT_FILE not writable, skipping patch" >&2
fi

# Always start the server (patch failure should not block startup)
exec uvicorn --factory speaches.main:create_app --host 0.0.0.0 --port 8000
