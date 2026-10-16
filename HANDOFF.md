# Learn Ateso: Content Handoff

**Status (2026-10-16): done.** The real content below has been generated into
`lib/data/fake/seed_data.dart` (5 levels, 29 lessons, 177 real vocabulary words) —
`flutter analyze` is clean and all tests pass. The source files have been moved
into `content/` (out of the project root, so a generated `.dart` sitting there
doesn't get swept up by `flutter analyze`), and the newer SRS/Domain
Model/Use Cases docs have replaced the stale copies in `docs/`. See `STATUS.md`
at the repo root for the full project status. Everything below is kept for
provenance and for re-running the generator when the spreadsheets change.

---

This folder holds the real Ateso content collected by the group. It replaces the
placeholder text in `lib/data/fake/seed_data.dart`. Requirements are in the SRS,
Domain Model and Use Cases docs (the copies that were in this folder were newer
than `docs/` and have since replaced them there).

## Rules for the AI working on this
- Never invent, translate, "correct" or guess Ateso. All Ateso comes from the
  spreadsheets below, written by a fluent speaker. If something is missing or looks
  wrong, add it to a list of questions for the Ateso-speaking groupmate.
- Anything not covered by real data stays clearly labeled PLACEHOLDER.

## Files (now in `content/`)
1. `content/Learn_Ateso_Beginner_Vocabulary_Full.xlsx` is the SOURCE OF TRUTH for
   vocabulary. Sheet `Beginner Words`: group header rows (column A only) followed by
   word rows (`english`, `ateso_word`). 177 of 180 words filled; Green, Brown and
   Vegetable are missing; "Child" was changed to "Children".
2. `content/generate_seed_data.py` reads file 1 (plus file 4 for sentence exercises)
   and writes `lib/data/fake/seed_data.dart` directly. Run from `content/`:
   `pip install openpyxl` then `python generate_seed_data.py`. Level layout, lesson
   sizes and the aptitude pass mark (4 of 5) are constants at the top of the script.
3. The generated `lib/data/fake/seed_data.dart`: 5 levels, 29 lessons, drop-in
   replacement for the old placeholder file. Re-run `flutter analyze`/`flutter test`
   after regenerating — tests that hardcode lesson counts per level may need updating
   if the spreadsheet's group sizes change (see `test/data/fake/`).
4. `content/Learn_Ateso_Sentence_Bank_Processed.xlsx` holds about 25k English-Ateso
   sentence pairs. Only the 50 rows with a `category` value in the `Beginner subset`
   sheet have been reviewed by a human. Use the rest as raw material (production
   exercises, Word/Phrase Lookup SRS 3.13), not as verified lesson content.
5. `content/Learn_Ateso_Vocabulary_Import_Ready.xlsx` is the same vocabulary reshaped
   to the Domain Model (`id, word, translation, audio_ref, category, level,
   example_sentence`). Prepared for a Firestore import — **not yet imported**; that's
   a production write and needs a deliberate decision/deploy step, not an automatic one.
   The `Needs attention` sheet lists the gaps above.

## Conventions
- Categories (controlled list): greetings, numbers, phrases, medical, grammar, family,
  food, daily_life, travel, work, time, emotions, civic.
- `audio_ref` holds the planned filename (`word_<ateso word>.mp3`, lowercase, underscores).
  No recordings exist yet, so `audioRef` stays null in the app until they do.
- The corpus is formal news-style text, so only rely on short, reviewed sentences.

## Known gaps (need the Ateso-speaking groupmate)
- Grammar notes for every lesson, and dialogue scripts (only one real dialogue exists).
- A clinical phrase set (e.g. "where does it hurt"). Body parts and "Hospital" exist,
  but no medical phrases yet.
- Words for Green, Brown, Vegetable, and a singular "Child".
- Audio recordings.
