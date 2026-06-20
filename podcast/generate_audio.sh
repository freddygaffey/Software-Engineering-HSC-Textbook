#!/usr/bin/env bash
#
# generate_audio.sh — convert lecture scripts into audio recordings locally.
#
# Episodes live as folders under  podcast/content/<episode>/  and each holds:
#     script.md          the spoken script   (input)
#     supplementary.md   read-along listings  (NOT spoken)
#     <voice>.m4a         one audio file per narrator voice the user can pick
#
# This renders content/<episode>/script.md to content/<episode>/<voice>.m4a,
# where <voice> is the Kokoro narrator voice used. Run it once per voice (see
# generate_all_voices.sh) to give every episode its set of selectable voices.
#
# Uses a LOCAL text-to-speech engine — no cloud, no API keys. It prefers
# Kokoro (a high-quality offline neural model), then Piper, then macOS `say`.
#
# Usage:
#   ./generate_audio.sh                       # every episode in content/
#   ./generate_audio.sh 20-01-What-is-AI-vs-ML   # one episode (folder name)
#   ENGINE=say  ./generate_audio.sh           # force the macOS engine
#   KOKORO_VOICE=bm_george ./generate_audio.sh   # render that voice
#
# Optional environment variables:
#   ENGINE        kokoro | piper | say  (default: auto-detect, kokoro preferred)
#   KOKORO_VOICE  narrator voice, e.g. af_heart, bm_george (default: af_heart)
#   KOKORO_VOICE2 question (second) voice for QUESTION:     (default: am_michael)
#   KOKORO_SPEED  speaking speed multiplier, e.g. 1.0       (default: 1.0)
#   KOKORO_LANG   a=American / b=British English            (default: a)
#   PIPER_BIN     path to the piper binary           (default: piper)
#   PIPER_MODEL   path to a piper .onnx voice model   (required for piper)
#   SAY_VOICE     macOS voice name, e.g. "Daniel"     (default: system voice)
#   SAY_RATE      macOS words-per-minute, e.g. 180    (default: engine default)

set -euo pipefail

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  VOICE SETTINGS — edit these to change the voices. That's it.             ║
# ╠══════════════════════════════════════════════════════════════════════════╣
# ║  Browse/preview all voices: https://huggingface.co/hexgrad/Kokoro-82M     ║
# ║  Female: af_heart af_bella af_nicole af_sarah bf_emma bf_isabella         ║
# ║  Male:   am_michael am_fenrir am_puck am_adam bm_george bm_lewis          ║
# ║  Prefix: a* = American English, b* = British English.                    ║
# ╚══════════════════════════════════════════════════════════════════════════╝

NARRATOR_VOICE="af_heart"      # main teaching voice (NARRATOR: lines)
QUESTION_VOICE="am_michael"    # second voice, asks questions (QUESTION: lines)
SPEAKING_SPEED="1.0"           # 1.0 = normal, 1.1 = a little faster, 0.9 = slower
ENGLISH="a"                    # a = American, b = British (match your voices)

# ── End of voice settings ───────────────────────────────────────────────────
# (Env vars still override, e.g.  KOKORO_VOICE=bm_george ./generate_audio.sh)
KOKORO_VOICE="${KOKORO_VOICE:-$NARRATOR_VOICE}"
KOKORO_VOICE2="${KOKORO_VOICE2:-$QUESTION_VOICE}"
KOKORO_SPEED="${KOKORO_SPEED:-$SPEAKING_SPEED}"
KOKORO_LANG="${KOKORO_LANG:-$ENGLISH}"

# Resolve paths relative to this script so it runs from anywhere.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_DIR="$HERE/content"
STRIPPER="$HERE/strip_markdown.py"

# Isolated venv that holds the Kokoro neural model (created during setup).
KOKORO_PY="$HERE/.tts-venv/bin/python"
KOKORO_DRIVER="$HERE/kokoro_tts.py"

# --- Pick an engine ----------------------------------------------------------
ENGINE="${ENGINE:-auto}"
PIPER_BIN="${PIPER_BIN:-piper}"

if [[ "$ENGINE" == "auto" ]]; then
  if [[ -x "$KOKORO_PY" ]] && "$KOKORO_PY" -c "import kokoro" >/dev/null 2>&1; then
    ENGINE="kokoro"
  elif command -v "$PIPER_BIN" >/dev/null 2>&1 && [[ -n "${PIPER_MODEL:-}" ]]; then
    ENGINE="piper"
  elif command -v say >/dev/null 2>&1; then
    ENGINE="say"
  else
    echo "Error: no TTS engine found. Install Kokoro/piper or run on macOS." >&2
    exit 1
  fi
fi

echo "TTS engine: $ENGINE"
[[ "$ENGINE" == "kokoro" ]] && echo "Kokoro narrator: $KOKORO_VOICE  question: $KOKORO_VOICE2  speed: $KOKORO_SPEED"

# --- Gather episodes to convert ---------------------------------------------
# An episode is any folder under content/ that contains a script.md.
shopt -s nullglob
EPISODES=()
if [[ $# -gt 0 ]]; then
  for arg in "$@"; do
    # Accept a folder name, a folder path, or a path to its script.md.
    if   [[ -f "$arg" && "$(basename "$arg")" == "script.md" ]]; then EPISODES+=("$(dirname "$arg")")
    elif [[ -d "$arg" && -f "$arg/script.md" ]]; then EPISODES+=("$arg")
    elif [[ -f "$CONTENT_DIR/$arg/script.md" ]]; then EPISODES+=("$CONTENT_DIR/$arg")
    else echo "Skipping (no script.md found): $arg" >&2; fi
  done
else
  for dir in "$CONTENT_DIR"/*/; do
    [[ -f "$dir/script.md" ]] && EPISODES+=("${dir%/}")
  done
fi

if [[ ${#EPISODES[@]} -eq 0 ]]; then
  echo "No episodes found in $CONTENT_DIR (each needs a <episode>/script.md)." >&2
  exit 0
fi

# --- Convert each episode ----------------------------------------------------
for ep in "${EPISODES[@]}"; do
  src="$ep/script.md"
  name="$(basename "$ep")"
  tmp_txt="$(mktemp -t tts.XXXXXX).txt"

  # Clean markdown into speakable prose (strips frontmatter + any appendix).
  python3 "$STRIPPER" "$src" > "$tmp_txt"

  if [[ ! -s "$tmp_txt" ]]; then
    echo "  ! $name/script.md produced no text, skipping"
    rm -f "$tmp_txt"
    continue
  fi

  case "$ENGINE" in
    kokoro)
      wav="$ep/$KOKORO_VOICE.wav"
      out="$ep/$KOKORO_VOICE.m4a"
      echo "  -> $name/$KOKORO_VOICE.m4a"
      "$KOKORO_PY" "$KOKORO_DRIVER" "$tmp_txt" "$wav" \
        --voice "$KOKORO_VOICE" \
        --voice2 "$KOKORO_VOICE2" \
        --speed "$KOKORO_SPEED" \
        --lang "$KOKORO_LANG"
      # Compress WAV -> m4a (small, plays everywhere); tag with the voice used.
      if command -v ffmpeg >/dev/null 2>&1; then
        ffmpeg -y -loglevel error -i "$wav" -c:a aac -b:a 96k \
          -metadata artist="Kokoro: $KOKORO_VOICE" \
          -metadata album="Voice: $KOKORO_VOICE / Q: $KOKORO_VOICE2" \
          -metadata comment="narrator=$KOKORO_VOICE question=$KOKORO_VOICE2 speed=$KOKORO_SPEED" \
          "$out" && rm -f "$wav"
      else
        echo "     (ffmpeg not found; left WAV at $wav)"
      fi
      ;;
    piper)
      out="$ep/$KOKORO_VOICE.wav"
      echo "  -> $name/$KOKORO_VOICE.wav"
      "$PIPER_BIN" --model "$PIPER_MODEL" --output_file "$out" < "$tmp_txt"
      ;;
    say)
      # AAC in an .m4a container — small and plays everywhere.
      out="$ep/${SAY_VOICE:-say}.m4a"
      echo "  -> $name/$(basename "$out")"
      say_args=(-o "$out" --data-format=aac -f "$tmp_txt")
      [[ -n "${SAY_VOICE:-}" ]] && say_args=(-v "$SAY_VOICE" "${say_args[@]}")
      [[ -n "${SAY_RATE:-}"  ]] && say_args+=(-r "$SAY_RATE")
      say "${say_args[@]}"
      ;;
    *)
      echo "Unknown ENGINE: $ENGINE" >&2; exit 1 ;;
  esac

  rm -f "$tmp_txt"
done

echo "Done. Audio written into each episode folder under: $CONTENT_DIR"
