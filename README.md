# Tournament Prediction Deployment

This repository contains the deployment configuration for the **Tournament Prediction Application**. The application allows groups of users to compete in predicting scorelines for major international football tournaments such as the FIFA World Cup and the UEFA European Championships.

## 📦 Repository Structure

This repository is designed to work alongside the following sibling repositories:

- `tournament-prediction-api` (Spring Boot backend)
- `tournament-prediction-ui` (React frontend)
- `tournament-prediction-deployment` (this repo, containing the deployment configuration)

## 🚀 Local Deployment

### Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your machine.
- [Java 21](https://adoptium.net/) and [Maven](https://maven.apache.org/) to build the API jar.
- The API's `database-handler` dependency available to Maven, either installed locally (`mvn install` in a `database-handler` checkout) or resolvable from GitHub Packages via your `~/.m2/settings.xml`.
- `.env` file containing necessary environment variables.

### Setup

1. Clone all required repositories into the same parent directory:
   ```sh
   git clone https://github.com/kanemullett/tournament-prediction-api.git
   git clone https://github.com/kanemullett/tournament-prediction-ui.git
   git clone https://github.com/kanemullett/tournament-prediction-deployment.git
   ```
2. Navigate to the deployment repository:
   ```sh
   cd tournament-prediction-deployment
   ```
3. Create a `.env` file in the root directory with the following variables:
   ```ini
   POSTGRES_USER=your_user
   POSTGRES_PASSWORD=your_password
   POSTGRES_DB=your_database
   REACT_APP_PREDICTOR_API_URL=http://localhost:5534
   # Optional, default to admin/admin
   KEYCLOAK_ADMIN_USER=admin
   KEYCLOAK_ADMIN_PASSWORD=admin
   ```

   | Variable | Used by | Description |
   | --- | --- | --- |
   | `POSTGRES_USER` | Postgres, API | Database user created on first start and used by the API. |
   | `POSTGRES_PASSWORD` | Postgres, API | Password for that user. |
   | `POSTGRES_DB` | Postgres, API | Database created on first start and used by the API. |
   | `REACT_APP_PREDICTOR_API_URL` | UI (build arg) | Base URL the browser uses to reach the API. Locally this is the API's host port, `http://localhost:5534`. It's baked in at build time, so rebuild the UI after changing it. |
   | `KEYCLOAK_ADMIN_USER` | Keycloak | Optional. Admin console user, created on Keycloak's first start. Defaults to `admin`. |
   | `KEYCLOAK_ADMIN_PASSWORD` | Keycloak | Optional. Password for that user. Defaults to `admin`. |

   *(The Postgres values are only relevant for local development so choose whatever you like. Postgres only applies them when its data volume is first created; run `docker compose down -v` to reset it.)*

4. Build the API jar. The API's Dockerfile copies a pre-built jar rather than building it:
   ```sh
   (cd ../tournament-prediction-api && mvn package)
   ```
   Re-run this whenever the API code changes, before rebuilding the containers.

5. Build and run the application:
   ```sh
   docker compose up --build
   ```

6. Once running:
   - UI: [http://localhost:2821](http://localhost:2821)
   - API docs (Swagger UI): [http://localhost:5534/swagger-ui.html](http://localhost:5534/swagger-ui.html)
   - API health: [http://localhost:5534/livez](http://localhost:5534/livez) (liveness) and [http://localhost:5534/readyz](http://localhost:5534/readyz) (readiness, includes the database)
   - Keycloak admin console: [http://localhost:8180/admin](http://localhost:8180/admin) (log in with `KEYCLOAK_ADMIN_USER`/`KEYCLOAK_ADMIN_PASSWORD`)

## 🛠️ Services

The application is composed of the following services:

| Service | Technology | Host port | Container port |
| --- | --- | --- | --- |
| Backend (`api`) | Spring Boot (Java 21) | `5534` | `8000` |
| Frontend (`ui`) | React, served by nginx | `2821` | `80` |
| Database (`postgres`) | PostgreSQL 15 | `7235` | `5432` |
| Auth (`keycloak`) | Keycloak 26 (dev mode) | `8180` | `8080` |
| Auth database (`keycloak-db`) | PostgreSQL 15 | none | `5432` |

The API waits for the Postgres healthcheck before starting, because Flyway applies database migrations at startup. CORS is set in `docker-compose.yml` to allow the UI on `http://localhost:2821` and the React dev server on `http://localhost:3000` (`npm start`).

## 🔐 Authentication (Keycloak)

Users log in through Keycloak. The UI gets a token using the authorization code flow with PKCE, and the API checks that token as an OAuth2 resource server.

The `predictor` realm is defined in [`charts/predictor/files/predictor-realm.json`](charts/predictor/files/predictor-realm.json). Docker Compose and the Helm chart both use this file. It contains:

| Item | Purpose |
| --- | --- |
| `predictor-ui` client | Public client for the React app. Redirect URIs and web origins come from `PREDICTOR_UI_URL` and `PREDICTOR_UI_DEV_URL`. |
| `predictor-api` client | The audience (`aud`) that the UI's access tokens are issued for. |
| `player` realm role | Every new user gets this role. |
| `admin` realm role | Assign it by hand to users who manage tournaments, fixtures and results. |

Self-registration is turned on, so anyone can create an account from the login page.

**The realm is only imported when it doesn't exist yet.** If you edit the JSON afterwards, either make the same change in the admin console, or wipe Keycloak's database: locally that's `docker compose rm -sf keycloak keycloak-db && docker volume rm tournament-prediction-deployment_keycloak_data`.

**Issuer.** Keycloak's hostname is fixed to the URL the browser uses (`http://localhost:8180` locally, `https://auth.providentia.kanemullett.com` in production). That makes every token's `iss` claim the same, however Keycloak was reached. The API gets two settings:

- `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI`: the public realm URL, which tokens are checked against.
- `SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI`: an internal URL for downloading the signing keys (`http://keycloak:8080/...` in Compose, the cluster service in Kubernetes). Inside the API container, `localhost:8180` would point at the API itself.

The UI doesn't use Keycloak yet. When it does, it needs the Keycloak URL (`http://localhost:8180` locally), the realm (`predictor`) and the client ID (`predictor-ui`).

## ☸️ Kubernetes: Keycloak

The chart deploys Keycloak at `ingress.hosts.auth` (`auth.providentia.kanemullett.com`). It has its own ingress and TLS certificate (`providentia-auth-tls`). It's turned off in `values-prod.yaml` (`keycloak.enabled: false`) until the steps below are done. After that, set it to `true`. Before the first install:

1. Create a `keycloak` database and a user that can access it on the managed Postgres cluster.
2. Point a DNS record for `auth.providentia.kanemullett.com` at the ingress load balancer.
3. Run `scripts/create-secrets.sh`. It now creates `predictor-keycloak-secret` (database credentials and a bootstrap admin) as well as the API secret.

After the first start, log in to `https://auth.providentia.kanemullett.com/admin`, create a permanent admin user in the `master` realm, and delete the bootstrap admin. To keep the admin console off the public internet, set `keycloak.ingress.exposeAdmin: false` and `keycloak.hostnameAdmin: http://localhost:8180`, then run `kubectl port-forward svc/predictor-keycloak 8180:80` and open `http://localhost:8180/admin`.

## 🔍 Monitoring & Logging

Currently, logging can be accessed via Docker Desktop by selecting the relevant container.

## 📌 Future Considerations

- Hosting options (to be determined).
- External API integration for fixture/result data.
- Improved logging and monitoring.

## 💜 License

This project is licensed under Кејн™.

