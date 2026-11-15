# Docker

Book Rhino runs as a set of containers with Docker Compose: the Rails app, the
Sidekiq background worker, the Vite dev server, Redis, and PostgreSQL with pgvector.

This runs the app in **development mode** inside the container: code reloading,
Rails error pages, and Vite HMR all work, and the working tree is bind-mounted
so edits on the host apply immediately without a rebuild.

## Quick start

```sh
docker compose up -d --build
docker compose logs -f web
```

The app is then on <http://localhost:3001>. The first boot creates the
database, loads the schema, and runs seeds, printing the admin login in
the web logs.

To pick your own login before the first boot, set these in `.env`:

```sh
POSTGRES_PASSWORD=choose-a-database-password
SEED_ADMIN_EMAIL=you@example.com
SEED_ADMIN_PASSWORD=choose-a-login-password
```

## Services

| Service | Runs | Notes |
| --- | --- | --- |
| `db` | `pgvector/pgvector:pg18` | PostgreSQL 18 with `pgvector`. Data in the `pg_data` volume. Not published to host port 5432 to avoid host collisions. |
| `redis` | `redis:7-alpine` | In-memory store for Sidekiq queues and Action Cable WebSockets. |
| `web` | `bin/rails server` | Serves the app on port 3001 and runs `db:prepare` on boot. |
| `worker` | `bundle exec sidekiq` | Sidekiq worker processing background jobs. |
| `vite` | `bin/vite dev` | Vite development server on port 3036 providing live HMR for frontend assets. |

All Ruby services share the same image (`Dockerfile.dev`) and the same bind
mount, so a code change applies to all of them immediately. Only `web` touches the
database on boot; `worker` and `vite` wait for the web health check so services
never race to prepare the database.

## Persistence

Everything that matters survives restarts, `docker compose down`, container
recreates, and image rebuilds:

- **Database** — the named volume `pg_data`.
- **Node dependencies** — the named volume `node_modules`, keeping Linux-compiled binaries separate from host macOS binaries.
- **Uploaded files** — `storage/` in the working tree, shared through the bind mount.
- **Login sessions & cache** — `tmp/` in the bind mount.

The database volume is only destroyed by an explicit request:

```sh
docker compose down        # keeps all database data
docker compose down -v     # deletes the database volume
```

### Why the volume is mounted at `/var/lib/postgresql`

Postgres 18 sets `PGDATA` to `/var/lib/postgresql/18/docker`, and the image
declares `/var/lib/postgresql` as its volume. Mounting the older
`/var/lib/postgresql/data` path leaves the real data directory in the
container's writable layer instead of the volume, so the database appears to
reset every time the container is recreated.

### Backup and restore

`--no-owner` matters: the dump is restored by a different role than the one
that owns the local database, and ownership statements would otherwise fail.

```sh
docker compose exec db pg_dump -U postgres --no-owner rino_book_development > backup.sql
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U postgres -d rino_book_development < backup.sql
```

## Configuration

### Database connection

`config/database.yml` reads standard libpq variables:

| Variable | In Docker | On the host |
| --- | --- | --- |
| `PGHOST` | `db` | unset, so local unix socket is used |
| `PGUSER` | `postgres` | unset, so current OS user is used |
| `PGPASSWORD` | `POSTGRES_PASSWORD` from `.env` | unset |
| `LOCAL_DB` | `rino_book_development` | `rino_book_development` |

All four are unset by default, so running `bin/dev` natively on the host keeps
using your local PostgreSQL without configuration changes.

### Redis connection

`config/initializers/sidekiq.rb` and `config/cable.yml` read `REDIS_URL`:

| Variable | In Docker | On the host |
| --- | --- | --- |
| `REDIS_URL` | `redis://redis:6379` | unset, defaults to `redis://localhost:6379` |

### LLM and inference services

`dotenv-rails` loads `.env` from the working tree. Host services (such as Ollama
or FreeToken) are reachable from within Docker at `host.docker.internal`.
In `.env`:

```sh
OLLAMA_API_BASE=http://host.docker.internal:1919/v1
```

## Everyday commands

```sh
docker compose logs -f web         # follow web application logs
docker compose logs -f worker      # follow Sidekiq background jobs
docker compose restart web         # restart after an environment change
docker compose up -d --build       # rebuild after a Gemfile or package.json change
docker compose run --rm web bash   # open a bash shell in a container
```

Rails console and database console:

```sh
docker compose exec web bin/rails console
docker compose exec db psql -U postgres -d rino_book_development
```

Run test suite inside the container:

```sh
docker compose exec web bundle exec rspec
```

## Importing existing local host data

To start Docker with the existing database you already have on your host machine:

```sh
# On the host
pg_dump --no-owner --no-privileges -d rino_book_development > backup.sql

# Into the container
docker compose up -d db
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U postgres -d rino_book_development < backup.sql
docker compose up -d
```
