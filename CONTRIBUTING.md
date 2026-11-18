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

- Conventional Commits: `<type>(<scope>): <summary> (<branch>)`. The main part is <= 50 chars; the trailing branch tag `(<branch>)` is NOT counted.
- Types: feature, fix, refactor, perf, test, docs, build, ci, chore, revert.
  - Note: branch prefix and commit type are both `feature` (full word) to avoid confusion.
  - Every commit on a feature/hotfix branch must end with the branch name in parentheses, e.g. `chore(git): add commit and pr conventions (feature/6)`. The hook enforces this.
- One logical change per commit/PR. Use `git commit` (opens `.gitmessage` template).
- Install hooks: `bin/setup-git-hooks`.

## Pull requests

- Target `develop` for features, `master` for hotfixes.
- Squash merge features (PR title = commit subject). Merge commits (`--no-ff`) for `develop` -> `master`.
- Fill the PR template; add `Refs:`/`Closes:` in the body.

## Tracking IDs

Tracking IDs from the other platform go in the `Refs:` footer and may be added later via the PR body or a follow-up commit. Never amend pushed commits.

## Example end-to-end flow (feature)

```sh
# 1. Start from an up-to-date develop
git checkout develop && git pull

# 2. Create the next feature branch (consecutive id)
git checkout -b feature/7

# 3. Make changes, then commit (opens .gitmessage template)
git add <intended files>
git commit                      # subject: feature(scope): short summary

# 4. Push and open a PR into develop
git push -u origin feature/7
# open PR: feature/7 -> develop (squash merge, PR title = commit subject)

# 5. After CI passes and review, squash-merge on GitHub, delete branch
# (auto-delete head branches is enabled)

# 6. Back locally: sync develop
git checkout develop && git pull

# Hotfix example (does not consume a feature number):
git checkout master && git pull
git checkout -b hotfix/$(date +%d%m%Y%H%M%S)
# ... fix, commit, push, PR into master, merge --no-ff, then one master->develop back-merge
```

## Example end-to-end flow (release to production)

```sh
# When develop is validated and ready to ship:
git checkout master && git pull
git merge --no-ff develop -m "chore(release): ship develop to master"
git tag -a v<next> -m "release <next>"
git push origin master --tags
# No release/* branch is created; no master->develop back-merge beyond the single release merge above.
```
