 Task: Generate the next podcast episode (find a gap, then write it)

You are an expert HSC Software Engineering tutor and scriptwriter. Your job is to
pick the next episode that hasn't been made yet and produce a complete, spec-compliant
episode for it, then report what you did.

Working root: `/Users/fred/Software-Engineering-HSC-Textbook`

## Step 0 — Read the rules and the plan (do this first, do not skip)

Read these in full before writing anything:
- `podcast/STYLE.md` — how scripts are written. This is binding. The §9 checklist is your gate.
- `podcast/SUPPLEMENTARY.md` — the two-file (`.md` + `.m4a`) format and the `## Appendix` contract.
- `podcast/content/Year12/README.md` — teaching order, conventions, case-study + mnemonic master lists.
- The four module plans under `podcast/content/Year12/*/PODCAST_PLAN.md` — the episode briefs.

If an explicit target was given (e.g. "do SSA 16-01"), skip Step 1 and use that. Otherwise:

## Step 1 — Find the gap (deterministic)

1. Build the planned episode list in **teaching order**: PFW → SSA → SA → SEP, reading the
   ordered episode tables in each `PODCAST_PLAN.md` (lessons, `-Part-N` splits, `XX-99`
   reviews, and `case_…` studies all count as episodes).
2. List what already exists: any `podcast/content/**/<basename>.md` that contains a real
   script (frontmatter + `NARRATOR:`/`QUESTION:` body), not just a plan file. Treat the
   legacy `content/20-01-What-is-AI-vs-ML/` as existing-but-legacy (skip unless told to redo).
3. **The gap = the first episode in teaching order that has no compliant `.md` script yet.**
   Pick exactly one. State which one and why before proceeding.

## Step 2 — Gather the material for that episode

- Open its brief in the relevant `PODCAST_PLAN.md` (dot-points, recap targets, interleaving,
  mnemonics, worked-example/exam seeds, appendix seeds, traps). This is your blueprint.
- Read the matching textbook source section under `docs/Year12/<Module>/Chapter-XX-*/XX-YY-*/index.md`
  (and `quiz.md` if present) for the actual content and correct technical detail.
- Confirm the exact syllabus dot-point wording in `podcast/resources/Software-Engineering-11-12-Syllabus.md`.
- Read the scripts of the **previous up-to-5 episodes** (in teaching order) so the spaced-repetition
  opener recaps them accurately, and skim any episodes named as cross-links so interleaving is real,
  not invented. Reuse already-coined mnemonics **verbatim**.

## Step 3 — Write the episode to spec

Produce one Markdown file. It must satisfy every box in STYLE.md §9. Non-negotiables:
- **YAML frontmatter** per SUPPLEMENTARY.md §4.1 (`title, module, lesson, kind, duration_minutes, audio`).
- **Two voices only:** `NARRATOR:` (teaches) and `QUESTION:` (only ever asks). ~80%+ narrator.
- **~5-min spaced-repetition opener** recapping the last up-to-5 episodes, leading into today.
- One **focused home topic** (~30–45 min; case studies 10–20). Never teach two topics.
- Audience = strong programmer weak on HSC framing: **don't re-teach programming**; teach the
  syllabus terms, exam phrasing, and mark-earning answers. Name the exact syllabus terminology.
- **≥2 real interleaving links** (back and/or forward, including cross-module) with preludes.
- **A mnemonic/memory hook for every memorisable list** (coin new ones; reuse existing ones unchanged).
- **At least one "pause the player" retrieval** `QUESTION:` (silent `[pause]` doesn't survive 4–5×).
- **Worked example(s)** with weak-vs-strong answer contrast and the mark-earning phrasing spelled out.
- **3–5 exam-style questions to close**, in real NESA verb format, each with a model answer.
- **Speakable prose:** no code/markdown/symbols in the spoken body; spell tricky terms phonetically.
- **`## Appendix`** at the very bottom (never spoken): real language-tagged code as `### Listing N — …`,
  plus NESA-style pseudocode where the topic is algorithmically examinable. Reference listings from the
  narration by label only — never "as you can see here".

## Step 4 — Save it

Write to `podcast/content/Year12/<Module>/<basename>.md` using the planned basename
(`XX-YY-Title`, `…-Part-N`, `XX-99-Module-Review-…`, or `case_…`). Do not generate audio.

## Step 5 — Output an episode report

After saving, print a short report:
- **Gap chosen** and why (its position in teaching order).
- **File written** (path) and target duration.
- **Syllabus dot-points + outcomes** covered (quote the dot-point).
- **Spaced-rep recap** targets used; **interleaving links** made (back/forward, which episodes/modules).
- **Mnemonics** coined vs reused; **Listings** added (code + pseudocode).
- **STYLE.md §9 checklist:** tick each box; flag any you couldn't fully satisfy and why.
- **Follow-ups:** e.g. case studies this episode now needs cashed in, or a `-Part-2` if it ran long.

Write the script, not a summary of one. If anything in the brief conflicts with STYLE.md,
STYLE.md wins.
