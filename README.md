# easy-admin

[![CI](https://github.com/Sergio-agile/easy-admin/actions/workflows/ci.yml/badge.svg)](https://github.com/Sergio-agile/easy-admin/actions/workflows/ci.yml)

Patient and consultation manager for an osteopathy practice: patient records, consultation notes with rich text, and PDF reports to send to patients.

**Stack:** Ruby on Rails 8.1, PostgreSQL, Hotwire (Turbo + Stimulus), Action Text, Bootstrap, PDF reports with headless Chromium (Ferrum). Deployed with Docker Compose.

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

`docker-compose.prod.yml` runs the app, PostgreSQL and Redis. HTTPS comes from the server's shared [Caddy](https://caddyserver.com) reverse proxy ([Sergio-agile/infra](https://github.com/Sergio-agile/infra), `proxy/`), which gets the Let's Encrypt certificate for `EASY_ADMIN_DOMAIN` (set in the proxy's `.env`; its DNS A record must point at the server) and imports this app's site block from `deploy/caddy/`. Start the proxy first: the app joins its external `proxy` network. The server needs a `.env.production` with `RAILS_MASTER_KEY` and `EASY_ADMIN_DATABASE_PASSWORD`.

```sh
docker compose -f docker-compose.prod.yml --env-file .env.production up -d --build
```
