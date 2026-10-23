# easy-admin

[![CI](https://github.com/Sergio-agile/easy-admin/actions/workflows/ci.yml/badge.svg)](https://github.com/Sergio-agile/easy-admin/actions/workflows/ci.yml)

Patient and consultation manager for an osteopathy practice: patient records, consultation notes with rich text, and PDF reports to send to patients.

**Stack:** Ruby on Rails 8.1, PostgreSQL, Hotwire (Turbo + Stimulus), Action Text, Bootstrap, wicked_pdf. Deployed with Docker Compose.

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

## Production

`docker-compose.prod.yml` runs the app, PostgreSQL, Redis and [Caddy](https://caddyserver.com), which serves the app over HTTPS with an automatic Let's Encrypt certificate. The server needs a `.env.production` with `RAILS_MASTER_KEY`, `EASY_ADMIN_DATABASE_PASSWORD` and `APP_DOMAIN` (a hostname whose DNS A record points at the server; ports 80 and 443 must be open).

```sh
docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```
