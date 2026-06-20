#!/usr/bin/env python3
"""Tiny Flask app to audition the voice samples. Run: .tts-venv/bin/python voice_app.py"""
import os
from flask import Flask, send_from_directory

DIR = os.path.join(os.path.dirname(__file__), "audio", "voice-samples")
app = Flask(__name__)


@app.route("/")
def index():
    files = sorted(f for f in os.listdir(DIR) if f.endswith((".wav", ".m4a")))
    rows = "".join(
        f'<tr><td><input type=checkbox class=pick value="{os.path.splitext(f)[0]}"></td>'
        f'<td>{os.path.splitext(f)[0]}</td>'
        f'<td><audio controls preload="none" src="/audio/{f}"></audio></td></tr>'
        for f in files
    )
    return f"""<!doctype html><meta charset=utf-8><title>Voices</title>
<style>body{{font:16px system-ui;margin:2rem}}td{{padding:.3rem 1rem}}
#out{{position:sticky;top:0;background:#ffd;padding:.6rem;font-family:monospace}}</style>
<h2>Voice samples ({len(files)})</h2>
<div id=out>Ticked: <span id=picked>(none)</span></div>
<table>{rows}</table>
<script>
function upd(){{
  let v=[...document.querySelectorAll('.pick:checked')].map(c=>c.value);
  document.getElementById('picked').textContent=v.length?v.join('  '):'(none)';
}}
document.querySelectorAll('.pick').forEach(c=>c.addEventListener('change',upd));
</script>"""


@app.route("/audio/<path:name>")
def audio(name):
    return send_from_directory(DIR, name)


if __name__ == "__main__":
    app.run(port=5005)
