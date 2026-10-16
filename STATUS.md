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
- Branding: GitHub repo renamed `SUN-ATES` → `Learn-Ateso`. Local folder intentionally left as `SUN ATES` (on hold per user).
- 45+ tests passing, analyzer clean as of last commit (`1f8c6f6`).

## Not started / deferred

1. **Mini-games** (`lib/features/hub/games_stub_screen.dart`) — still a "coming soon" stub, ungated for guests per the nav doc.
2. **Social following/friends** — distinct from the leaderboard (which is done); no friends/follow system exists yet.
3. **Offline progress-sync queue** (SRS 4.1/4.3) — only offline *content* access is done. Completing a lesson still requires connectivity when `USE_FIREBASE=true`; queuing/auto-syncing writes made offline is not implemented.
4. **Real Ateso content** — all current content is clearly-labeled placeholder text in `lib/data/fake/seed_data.dart` (SRS §6.1). Needs sourcing from fluent speakers.
5. **Admin allowlist for content writes** — Firestore rules currently allow any non-anonymous account to write content collections; a real admin claim (custom auth claim + Cloud Function/Admin SDK) is flagged as needed before wider release.
6. **Audio assets** — no real pronunciation clips exist; audio buttons render disabled throughout.
7. **iOS** — codebase stays cross-platform but is untested; only Android is buildable on this dev machine.

## Next up

Picking up with **mini-games**, the next item in the deferred list with no Firebase-rules dependency blocking progress (unlike the social-following/leaderboard-adjacent work, which is already live).
