# Learn Ateso — Build Status

_Last updated: 2026-10-16_

Duolingo-style Flutter app teaching Ateso. CPE3106 (Mobile Application Development) group project, Soroti University. Full requirements in `docs/` (SRS, Domain Model, Use Cases, Navigation Workflow). Implementation plan: `C:\Users\Benjamin\.claude\plans\ok-following-documents-in-golden-acorn.md`.

## Done

- **Core learning path MVP (M1-M13)**: onboarding, guest/signup/login, lesson list with real sequential level/lesson locking, full lesson pipeline (vocab, grammar, quiz, sentence-building, conversation practice), lesson completion (points/streak/puzzle-piece reveal), aptitude skip-test, guest-to-full-account upgrade, Page 2 hub stubs.
- **Firebase wiring (Phase 5)**: real `learn-ateso` Firebase project (Firestore + Auth), replacing in-memory fakes by default. Verified end-to-end on-device.
- **Hardening pass**: `AuthGate` auto-redirects already-signed-in users to Home; `firestore.rules` tightened so only non-anonymous accounts write content; unit tests for Firebase repos.
- **Village & puzzle visuals**: `PuzzleImageReveal` widget uncovers a themed icon as puzzle pieces are earned; real `VillageView` on the Profile tab with a decay state (thriving/fading/overgrown).
- **Points leaderboard**: top-N-by-points list on the Village screen, backed by a denormalized public `leaderboard/{uid}` doc. Rules deployed and verified live.
- **Weekly quests**: `QuestsScreen` with 3 rotating weekly challenges (4-template pool, deterministic rotation by week number), live progress bars, +20 bonus on completion. Rules for `users/{uid}/quests` written — **deployed and confirmed working** (per memory, user ran the deploy).
- **Offline lesson downloads**: real Downloads screen, per-device download/remove via `shared_preferences`, `CachedContentRepository` decorator serves downloaded content offline with zero changes to lesson screens.
- **Word Match mini-game**: replaces the Games tab stub. Word-matching challenge drawing vocabulary from unlocked levels, modest points via `ProgressRepository.recordMiniGameScore`.
- **Real Ateso content wired in**: a groupmate dropped real vocabulary/sentence spreadsheets at the project root (`HANDOFF.md`), now organized under `content/`. `content/generate_seed_data.py` reads them and writes `lib/data/fake/seed_data.dart` directly — 177 real vocabulary words across 5 levels / 29 lessons. Quizzes and aptitude tests are generated from that real vocabulary; grammar notes, most dialogues, and sentence exercises for lessons with no real multi-word phrase yet stay clearly-labeled PLACEHOLDER (SRS §6.1). No audio recordings exist yet (`audioRef` stays null). See `HANDOFF.md` for the full data provenance and known content gaps (missing words, grammar notes, clinical phrases, dialogue scripts) that still need the Ateso-speaking groupmate. The newer SRS/Domain Model/Use Cases docs that came with this drop have replaced the stale copies in `docs/`.
- Branding: GitHub repo renamed `SUN-ATES` → `Learn-Ateso`. Local folder intentionally left as `SUN ATES` (on hold per user).
- 55 tests passing (1 intentionally skipped, see `fake_progress_repository_test.dart`), analyzer clean.

## Not started / deferred

1. **Social following/friends** — distinct from the leaderboard (which is done); no friends/follow system exists yet.
2. **Offline progress-sync queue** (SRS 4.1/4.3) — only offline *content* access is done. Completing a lesson still requires connectivity when `USE_FIREBASE=true`; queuing/auto-syncing writes made offline is not implemented.
3. **Admin allowlist for content writes** — Firestore rules currently allow any non-anonymous account to write content collections; a real admin claim (custom auth claim + Cloud Function/Admin SDK) is flagged as needed before wider release.
4. **Audio assets** — no real pronunciation clips exist; audio buttons render disabled throughout.
5. **iOS** — codebase stays cross-platform but is untested; only Android is buildable on this dev machine.
6. **Production Firestore content import** — `content/Learn_Ateso_Vocabulary_Import_Ready.xlsx` is prepared for this but not yet imported; it's a production write, left for a deliberate decision rather than done automatically.
7. **Remaining content gaps** (need the Ateso-speaking groupmate, per `HANDOFF.md`): grammar notes for every lesson, most dialogue scripts, a clinical phrase set, words for Green/Brown/Vegetable/singular "Child", and all audio recordings.

## Next up

Content gaps above are now blocked on the Ateso-speaking groupmate, not on engineering work. Remaining engineering-only items: social following/friends, the offline progress-sync queue, and the content-write admin allowlist — any of these can be picked up next.
