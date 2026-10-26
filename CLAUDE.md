# easy-admin

Patient and consultation manager for a single osteopathy practice. Rails 8.1, PostgreSQL, Hotwire, Bootstrap, Ferrum (headless Chromium) for PDFs.

## Development

Everything runs in Docker (a non-Docker Rails often holds port 3000):

```sh
APP_PORT=3001 docker compose up                                           # app on http://localhost:3001
docker compose exec -T -e RAILS_ENV=test web bundle exec rspec            # tests
docker compose exec -T web bundle exec rubocop                            # lint (-a to autocorrect)
docker compose exec -T web bundle exec brakeman --no-pager -q             # security scan
docker compose exec -T web bundle exec bundler-audit check --update       # vulnerable gems
```

CI (`.github/workflows/ci.yml`) runs all four on every PR and on `main`.

## Workflow

- One branch per backlog item: `feature/EA-00NN-short-name`. Commit messages and PR descriptions in English.
- Before every commit: RuboCop and RSpec must pass. Never disable a cop or skip a check to get green; fix the code or discuss it.
- Every feature and every bug fix comes with a spec. Bugs get a spec that fails before the fix.
- The repo is public: never commit secrets, patient data, server addresses or real user emails.

## Code standards

- Style is `rubocop-rails-omakase` (`.rubocop.yml`); don't add local style overrides.
- Keep controllers thin: queries and search logic belong in model scopes, not controllers.
- Patient data is health data: filter new personal fields from logs (`config/initializers/filter_parameter_logging.rb`) and keep every page behind `authenticate_user!`.
- New gems need a reason; prefer what Rails ships with.

## Design and performance

- Before changing a feature, look for the Rails-idiomatic design: scopes and concerns in models, POROs for domain objects (e.g. a report), Turbo Frames for partial page updates, shared partials instead of duplicated ones. Refactor the code you touch, not the whole app.
- Check performance on every change: no N+1 (`includes`), indexes for new query columns, paginated lists, and memory (production has 1 GB RAM).
- When replacing a dependency, write specs of the current behavior first, then swap.

## Tests

- Request specs for behavior (`spec/requests`), model specs for validations and scopes.
- Keep the suite fast: prefer `build` over `create`, create only the records a test needs, and avoid factory callbacks that create associations by default.
- `sign_in(user)` from `spec/support/authentication_helpers.rb` logs a user in for request specs.
