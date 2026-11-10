# AGENTS.md

## Project
- Rails 8.1.3 + Ruby 3.4.10 (`.ruby-version`) app with ERB views, React islands, GraphQL, and PostgreSQL. CI uses Node 20.
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

## Git / CI
- CI runs on `master`, `develop`, `feature/**`, `release/**`, `hotfix/**`; PRs target `master`/`develop`. Historical hotfix branches are named `hotfix/YYYYMMDDHHMMSS`.
