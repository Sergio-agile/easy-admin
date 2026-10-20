# easy-admin

[![CI](https://github.com/Sergio-agile/easy-admin/actions/workflows/ci.yml/badge.svg)](https://github.com/Sergio-agile/easy-admin/actions/workflows/ci.yml)

Patient and consultation manager for an osteopathy practice: patient records, consultation notes with rich text, and PDF reports to send to patients.

**Stack:** Ruby on Rails 7.1, PostgreSQL, Hotwire (Turbo + Stimulus), Action Text, Bootstrap, wicked_pdf. Deployed with Docker Compose.

## Running locally

```sh
APP_PORT=3001 docker compose up
docker compose exec web bin/rails users:create EMAIL=you@example.com   # prints a random password
```

The app is then available at http://localhost:3001.

## Quality checks

```sh
docker compose exec -T -e RAILS_ENV=test web bundle exec rspec
docker compose exec -T web bundle exec rubocop
docker compose exec -T web bundle exec brakeman --no-pager
docker compose exec -T web bundle exec bundler-audit check --update
```

All of them run in GitHub Actions on every pull request.
