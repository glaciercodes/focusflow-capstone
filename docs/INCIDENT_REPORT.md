# Incident Report — Sessions Fail to Save (Missing Database Schema)

**Project:** FocusFlow — Dockerized 3-Tier App with Full CI/CD
**Date of incident:** 27 July 2026
**Environment:** Local Docker Compose deployment (Docker 29.6.1, Docker Desktop on Windows 11 / WSL2)
**Reported by:** Group 5

---

## 1. Symptom

After starting the full stack with `docker compose up --build`, the frontend loaded
normally at `http://localhost`, but clicking **Save** on a new focus session did
nothing — no error was shown to the user, and the session did not appear in the
session list.

How we observed it:

- **Browser (Chrome DevTools → Network tab):** the `POST` request to the backend
  API returned **HTTP 500 Internal Server Error** on every save attempt.

  > Screenshot: `screenshots/incident-01-network-500.png`

- **Container logs (`docker compose up` terminal):** the database container logged
  the same error repeatedly, once per save attempt:

  ```
  focusflow_db | 2026-07-27 10:52:33.989 UTC [152] ERROR:  relation "focus_sessions" does not exist at character 13
  focusflow_db | 2026-07-27 10:52:33.989 UTC [152] STATEMENT:  INSERT INTO focus_sessions
  focusflow_db |               (task, category, duration, mood)
  focusflow_db |               VALUES ($1,$2,$3,$4)
  ```

  The initial page load also failed to fetch existing sessions:

  ```
  focusflow_db | 2026-07-27 10:52:29.113 UTC [144] ERROR:  relation "focus_sessions" does not exist at character 15
  focusflow_db | 2026-07-27 10:52:29.113 UTC [144] STATEMENT:  SELECT * FROM focus_sessions ORDER BY created_at DESC
  ```

  > Screenshot: `screenshots/incident-02-db-error-logs.png`

---

## 2. Investigation Trail

Checks performed in order, and what each one ruled in or out:

1. **Did the frontend load?** Yes — `http://localhost` served the UI and static
   assets (nginx access log showed `GET / 304`, `GET /assets/... 304`).
   → **Ruled out** the frontend container and nginx as the cause.

2. **Did the browser request reach the backend?** Yes — DevTools showed the `POST`
   leaving the browser and receiving a 500 response, meaning the backend was
   reachable and responding.
   → **Ruled out** a network/port problem between browser and backend.

3. **Was the backend running and connected to the database?** Yes — backend logs
   showed `Server running on port 5000`, and the Postgres error proved the query
   *arrived* at the database. A connection failure would look different
   (`ECONNREFUSED` / timeout), not a SQL error.
   → **Ruled out** backend crash and DB connectivity.

4. **Did the table exist in the database?** No:

   ```bash
   docker exec -it focusflow_db psql -U focus_user -d focusflow -c "\dt"
   # → "Did not find any relations."
   ```

   → **Ruled in** a missing schema: the database was running but completely empty.

   > Screenshot: `screenshots/incident-03-no-relations.png`

5. **Why was the schema never created?** The repo contains
   `database/init.sql` with the `CREATE TABLE focus_sessions` statement, and the
   official Postgres image auto-runs any script placed in
   `/docker-entrypoint-initdb.d/` on first initialization. The database startup
   log showed:

   ```
   focusflow_db | /usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*
   ```

   i.e. that directory was **empty inside the container** — `init.sql` was never
   mounted into it. Checking `docker-compose.yml` confirmed the `database` service
   only mounted the data volume, not the init script.

   > Screenshot: `screenshots/incident-04-ignoring-initdb.png`

---

## 3. Root Cause

`docker-compose.yml` never mounted `database/init.sql` into the Postgres
container's `/docker-entrypoint-initdb.d/` directory, so the database was
initialized without any schema and every `SELECT`/`INSERT` against
`focus_sessions` failed with *relation does not exist*.

---

## 4. Fix

**Change:** added one line to the `database` service in `docker-compose.yml`:

```yaml
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql   # ← added
```

**Applied with a full re-initialization** (Postgres only runs init scripts on a
*brand-new* data volume, so the old empty volume had to be removed):

```bash
docker compose down -v        # -v removes the postgres_data volume
docker compose up --build
```

*Note: the first re-deploy attempt still failed because the edited
`docker-compose.yml` had not been saved before re-running compose — Docker reads
the file only at `up` time. Lesson recorded: always confirm the file is saved,
then recreate the containers.*

**Proof — before:**

```
focusflow_db | /usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*
focusflow_db | ERROR:  relation "focus_sessions" does not exist at character 13
```

**Proof — after:** the startup log now runs the script, the table exists, and a
session saved through the UI is visible inside the database:

```bash
docker exec -it focusflow_db psql -U focus_user -d focusflow -c "\dt"
#            List of relations
#  Schema |      Name      | Type  |   Owner
# --------+----------------+-------+------------
#  public | focus_sessions | table | focus_user

docker exec -it focusflow_db psql -U focus_user -d focusflow -c "SELECT * FROM focus_sessions;"
# → shows the session entered through the web UI
```

The UI now saves sessions and displays them in the list immediately.

> Screenshots: `screenshots/incident-05-initdb-running.png`,
> `screenshots/incident-06-table-exists.png`,
> `screenshots/incident-07-app-working.png`

---

## 5. Design Reflection

Our Phase 0 design made this failure *more likely to happen* and *harder to
catch*. Schema creation depended on a single, easy-to-miss line of volume wiring
in `docker-compose.yml`, and nothing in the system verified the schema actually
existed: the database healthcheck (`pg_isready`) only confirms Postgres accepts
connections, not that the application's tables are present — so compose reported
the database "healthy" while the app was effectively broken. The failure was also
invisible to the user because the frontend swallowed the API error silently.
Going forward we would (a) make the healthcheck query the real table
(e.g. `psql -c "SELECT 1 FROM focus_sessions LIMIT 1"`) so a missing schema fails
fast at startup, (b) add a backend `/health` endpoint that checks database
reachability end-to-end — which we need anyway for the blue-green deployment
gate — and (c) surface API errors in the UI instead of failing silently. The fix
was one line, but the design change is what stops the same class of failure from
reaching the investor demo.
