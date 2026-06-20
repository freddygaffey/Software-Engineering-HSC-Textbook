#!/usr/bin/env bash
#
# generate_all_voices.sh — render every episode in every selectable narrator
# voice. Each voice lands inside the episode folder as content/<episode>/<voice>.m4a,
# so the viewer can offer them as a voice picker.
# The question (second) voice is the same across all of them.
#
# Usage:  ./generate_all_voices.sh                       # all episodes, all voices
#         ./generate_all_voices.sh 20-01-What-is-AI-vs-ML   # one episode, all voices

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The canonical set of narrator voices the user can choose between.
# (Matches the <voice>.m4a files that end up in each episode folder.)
NARRATORS=(af_heart am_onyx am_santa bf_isabella bm_daniel bm_george)

# Second voice used for QUESTION: lines in every version.
QUESTION_VOICE="bm_fable"

for voice in "${NARRATORS[@]}"; do
  echo "═══ Rendering narrator: $voice ═══"
  KOKORO_VOICE="$voice" \
  KOKORO_VOICE2="$QUESTION_VOICE" \
    "$HERE/generate_audio.sh" "$@"
done

echo "All voices done. Each episode folder now holds one .m4a per voice."
