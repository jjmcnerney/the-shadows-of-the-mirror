# Contributing

Thanks for working on **The Shadows of the Mirror**. This is a small, two-person
Godot 4.7 project, so the process below is deliberately light — just enough to
keep `master` always buildable and the history readable.

## Tooling
- **`gh` CLI** is the preferred interface for GitHub (PRs, issues, releases).
  Authentication is already set up on the dev box (`gh auth status` → logged in
  as `jjmcnerney`). Use `gh` for everything GitHub-related; fall back to
  `git`/`curl` only if `gh` is unavailable.
- Remote is HTTPS (`git` uses `gh` as its credential helper), so pushes work
  without re-entering a token.

## Branch policy

| Concept | Rule |
|---------|------|
| `master` | Always buildable. Tests green, Windows export clean. **Never** commit broken work directly to `master`. |
| Feature branches | Do all work on a branch off `master`: `git checkout -b feat/short-desc`. |
| Branch naming | `type/short-desc` — `feat`, `fix`, `docs`, `chore`, `test`, `refactor`, `ci`. Matches our commit style. |
| Merging | Merge feature branches into `master` via PR (`gh pr create`), then delete the branch. Squash-merge preferred for a clean linear history. |
| Tags (gates) | Milestones are tagged on `master` (e.g. `phase-1`, `phase-2`). A gate tag means the acceptance criteria in `docs/phase1-gate.md` (etc.) pass. |

Mental model: **`master` = shipped truth · branches = workbenches · tags = "this milestone passed."**

## Before you merge / tag
1. Run the headless test harness and confirm it prints `=== All tests passed ===`:
   ```bash
   ~/godot --headless --path . res://scenes/main/test_root.tscn
   ```
2. Rebuild the Windows export and confirm it succeeds:
   ```bash
   ~/godot --headless --path . --export-release "Windows" export/shadows_of_the_mirror.exe
   ```
3. `export/` is git-ignored — never commit the built `.exe`/`.pck`.

## Commit messages (Conventional Commits)
```
type(scope): short summary

Optional longer explanation. Wrap at ~72 chars.
```
Types: `feat`, `fix`, `docs`, `test`, `refactor`, `ci`, `chore`, `perf`.
Example: `feat: bow pickup grants bow + starter arrows (Phase 1 gate 9)`

## Typical workflow
```bash
git fetch origin
git checkout master && git pull origin master
git checkout -b feat/heart-pieces
# ... make changes, commit ...
git push -u origin HEAD
gh pr create --title "feat: heart pieces" --body "..."   # or just merge locally for tiny changes
# after merge:
git checkout master && git pull origin master
git branch -d feat/heart-pieces
```

## Documentation
- Gate acceptance criteria live in `docs/phase1-gate.md` (and future
  `phase-2-gate.md`, etc.). Update them when a gate's definition changes.
- Milestone narrative goes in `docs/phaseN-summary.md`.
- Keep `README.md` accurate (controls, test/export commands).

## Questions?
Ping @jjmcnerney. For AI-agent-assisted changes, the agent follows this file
verbatim; if a step can't be completed, it reports the blocker rather than
faking the result.
