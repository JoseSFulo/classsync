# Contributing

## Branches

- `main` always works. Nobody pushes directly to it.
- Create a branch for every task. Name it `type/short-description`.
- Types: `feat` (new feature), `fix` (bug fix), `docs`, `test`, `chore` (setup, config).
- Example: `feat/week-view`

## Commits

Format: `type(scope): summary`

- Write the summary in lowercase, present tense, no period.
- Example: `feat(timetable): add overlap check`
- One logical change per commit.

## Pull requests

1. Pull the latest `main` before starting a task, and merge it into your branch daily.
2. Keep pull requests small and focused on one purpose.
3. The other person reviews and approves before merging.
4. Merge with **Squash and merge**, then delete the branch.

## Ownership

- Frontend owns `app/`, except `app/lib/data/firebase/`.
- Backend owns `app/lib/data/firebase/` and `firebase/`.
- Only the frontend developer edits `pubspec.yaml`, `main.dart`, and the router file. Backend asks for changes through an issue or message.
- Both write in `docs/`.

## Contract

`app/lib/domain/` and `docs/contract.md` define how frontend and backend talk to each other.

- Adding something optional: pull request approved by both.
-  Renaming, removing, or changing meaning: agree first, and describe the change in the pull request.

## Never commit

- Firebase config: `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`
- Keystores, `key.properties`, service-account keys
- `.env` files
- Build folders

Commit `.example` templates instead. Everything in a public repo stays visible forever, even after deletion.