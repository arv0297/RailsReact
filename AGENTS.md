# AGENTS.md

## Project
- Rails 8.1.4.1 + Ruby 3.4.10 (`.ruby-version`) app with ERB views, React islands, GraphQL, and PostgreSQL. CI uses Node 20.
- Application module is `App`; GraphQL schema is `AppSchema` (`app/graphql/app_schema.rb`).

## Setup and run
- `bin/setup` installs gems, runs `db:prepare`, clears logs, then starts `bin/dev`; use `bin/setup --skip-server` in automation.
- `bin/dev` (foreman + `Procfile.dev`) runs Puma on `0.0.0.0:3000` and `npm run build:watch`.
- `config/database.yml` is intentionally gitignored and absent. Provide it locally or set `DATABASE_URL`; CI uses `DATABASE_URL=postgres://postgres:postgres@localhost:5432/rails_test`.
- `.env` is local-only. `docker-compose.yml` reads `POSTGRES_*` for the `db` service but does not set `DATABASE_URL` for `web`, so the web container still needs `config/database.yml`.

## JavaScript / assets
- esbuild (jsbundling) bundles only top-level `app/javascript/*.*` into gitignored `app/assets/builds`. The layout includes only `application`; import components from subdirectories.
- `.js` uses the JSX loader, so JSX in `.js` is valid.
- Run `npm run build` before booting/testing without `bin/dev`; Propshaft serves assets (`config/initializers/assets.rb`). Do not reintroduce importmap/Sprockets.
- React mounts on `DOMContentLoaded` into `#root` and `#chart` (`app/javascript/application.js`).

## Tests
- RSpec is the suite CI actually runs: `bin/rails db:test:prepare && bundle exec rspec`.
- Single spec: `bundle exec rspec spec/models/user_spec.rb` (append `:LINE` for one example).
- Every spec needs `require "rails_helper"` and an explicit `type:` (e.g. `:model`, `:request`, `:system`); spec-type inference is disabled.
- System specs use rack_test by default; tag `js: true` for Selenium headless Chrome. Build JS first and have Chrome available.
- `test/` and `bin/ci` (`config/ci.rb`) are leftover Minitest/seeds flows, not RSpec. Do not use `bin/ci` to verify RSpec changes.

## Lint / security
- `bin/rubocop` (rubocop-rails-omakase), `bin/brakeman --no-pager`, `bin/bundler-audit`, `npm audit`.

## App-specific
- GraphQL endpoint: `POST /graphql` -> `GraphqlController#execute`; GraphiQL is development-only at `/graphiql`.
- Root is `home_pages#home`; `users` routes cover index/show/new/create/edit/update only (no destroy).
- `app/models/user.rb` validation messages are Spanish; keep new messages consistent.
- `db/seeds.rb` is gitignored; do not rely on seeds existing.
- `config/deploy.yml` / `.kamal` are placeholders (fake IP and localhost registry); do not deploy from them without real config.
- `image_processing` is 2.x, which no longer pulls `ruby-vips`/`mini_magick` itself. `ruby-vips` is a separate Gemfile entry and Rails 8.1 aborts boot without it (Active Storage's vips transformer). `libvips` must be installed on the system (Docker/CI already have it).
- The queue DB uses schema files, not migrations: `db/queue_schema.rb`, `db/cache_schema.rb`, `db/cable_schema.rb` (`config.solid_queue.connects_to` in `production.rb`). When upgrading `solid_queue`, copy any new tables/columns from the gem's install template or `solid_queue:update` generator into `db/queue_schema.rb`.

## Dependencies / upgrades
- `.github/dependabot.yml` groups updates: ONE PR per ecosystem per week (bundler, npm, github-actions). Do not split grouped PRs.
- When upgrading gems for CI to pass, run the full security suite: `bin/bundler-audit` must report no vulnerabilities (it checks transitive deps like `rails-html-sanitizer`, `nokogiri`, `rack` that Dependabot PRs don't cover).
- Ruby is not installed on this machine. Validate gem changes in Docker:
  `docker run --rm -v $PWD:/app -w /app -e BUNDLE_PATH=vendor/bundle -e RAILS_ENV=test -e DATABASE_URL=... ruby:3.4.10-slim bash -lc 'apt-get update && apt-get install -y --no-install-recommends build-essential libpq-dev libyaml-dev libvips; gem install bundler -v 2.6.9 && bundle _2.6.9_ install && bundle exec rspec'`
  (run a `postgres:16` container on a docker network to point `DATABASE_URL` at).
- Keep `Gemfile.lock`'s `BUNDLED WITH 2.6.9` when regenerating it.

## Documentation rules
- ALWAYS update `CHANGELOG.md` (record of every change per feature/branch) and this file (`AGENTS.md`) after finishing a task. They grow alongside the project.
- ONLY skip updating these files if the user explicitly says they just want the task run without documentation updates.

## Git / CI
- CI runs on `master`, `develop`, `feature/**`, `release/**`, `hotfix/**`; PRs target `master`/`develop`. Historical hotfix branches are named `hotfix/YYYYMMDDHHMMSS`.
- Branch flow (ALWAYS follow): new work branches off `develop` as `feature/YYYYMMDDHHMMSS` -> PR into `develop` -> `develop` is merged into `master` only after the feature set is validated. Never keep committing on a feature branch after its PR was merged; start a fresh branch.
- `master` is the production source. Planned environments: a QA environment (closest to production, running the entire project, not just local) to validate before merging to `master`, then a production environment for deploys.
