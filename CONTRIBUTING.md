# Contributing

## Branching

- Integration branch: `develop`. Production branch: `master`.
- **No release branches and no `x.y.z` version branches.** Features are tracked only by ID.
- Feature branches: `feature/<n>` where `<n>` is the next consecutive integer (highest used + 1). One task per branch.
- Hotfix branches: `hotfix/<timestamp>` where the timestamp is generated with:
  ```sh
  date +%d%m%Y%H%M%S   # day month year hour minute second
  ```
  Hotfixes use timestamps so they never consume a feature number.
- Never merge `master` -> `develop` (avoids knotted history). Only `develop` -> `master` for releases.

## Commits

- Conventional Commits: `<type>(<scope>): <summary>` (subject <= 50 chars).
- Types: feat, fix, refactor, perf, test, docs, build, ci, chore, revert.
- One logical change per commit/PR. Use `git commit` (opens `.gitmessage` template).
- Install hooks: `bin/setup-git-hooks`.

## Pull requests

- Target `develop` for features, `master` for hotfixes.
- Squash merge features (PR title = commit subject). Merge commits (`--no-ff`) for `develop` -> `master`.
- Fill the PR template; add `Refs:`/`Closes:` in the body.

## Tracking IDs

Tracking IDs from the other platform go in the `Refs:` footer and may be added later via the PR body or a follow-up commit. Never amend pushed commits.
