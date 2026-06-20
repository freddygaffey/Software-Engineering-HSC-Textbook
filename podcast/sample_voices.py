#!/usr/bin/env python3
"""Render the same sample line in every Kokoro voice, for auditioning.

Writes one WAV per voice into audio/voice-samples/<voice>.wav.
"""
import os
import sys

import numpy as np
import soundfile as sf

SAMPLE_RATE = 24000
OUT_DIR = os.path.join(os.path.dirname(__file__), "audio", "voice-samples")

SAMPLE_TEXT = (
    "Welcome back. Today we're looking at the data flow diagram, one modelling "
    "tool the HSC syllabus expects you to know cold. Here's the thing the marker "
    "rewards: the data labels on every single arrow. Miss those and you drop marks."
)

# All English voices in Kokoro v1.0. a* = American, b* = British.
VOICES = {
    "a": [
        "af_heart", "af_bella", "af_nicole", "af_aoede", "af_kore", "af_sarah",
        "af_nova", "af_sky", "af_alloy", "af_jessica", "af_river",
        "am_michael", "am_fenrir", "am_puck", "am_echo", "am_eric",
        "am_liam", "am_onyx", "am_adam", "am_santa",
    ],
    "b": [
        "bf_emma", "bf_isabella", "bf_alice", "bf_lily",
        "bm_george", "bm_fable", "bm_lewis", "bm_daniel",
    ],
}


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    from kokoro import KPipeline

    pipelines = {}
    for lang, voices in VOICES.items():
        pipe = pipelines.get(lang) or KPipeline(lang_code=lang)
        pipelines[lang] = pipe
        for v in voices:
            try:
                chunks = []
                for _gs, _ps, audio in pipe(SAMPLE_TEXT, voice=v):
                    chunks.append(np.asarray(audio, dtype=np.float32))
                if not chunks:
                    print(f"  {v}: no audio", file=sys.stderr)
                    continue
                out = os.path.join(OUT_DIR, f"{v}.wav")
                sf.write(out, np.concatenate(chunks), SAMPLE_RATE)
                print(f"  {v:<14} -> {os.path.basename(out)}")
            except Exception as e:  # keep going if one voice fails
                print(f"  {v:<14} FAILED: {e}", file=sys.stderr)

    print(f"\nDone. Samples in {OUT_DIR}")


if __name__ == "__main__":
    main()
