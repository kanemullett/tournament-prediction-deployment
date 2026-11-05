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
   ```

   | Variable | Used by | Description |
   | --- | --- | --- |
   | `POSTGRES_USER` | Postgres, API | Database user created on first start and used by the API. |
   | `POSTGRES_PASSWORD` | Postgres, API | Password for that user. |
   | `POSTGRES_DB` | Postgres, API | Database created on first start and used by the API. |
   | `REACT_APP_PREDICTOR_API_URL` | UI (build arg) | Base URL the browser uses to reach the API. Locally this is the API's host port, `http://localhost:5534`. It's baked in at build time, so rebuild the UI after changing it. |

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

## 🛠️ Services

The application is composed of the following services:

| Service | Technology | Host port | Container port |
| --- | --- | --- | --- |
| Backend (`api`) | Spring Boot (Java 21) | `5534` | `8000` |
| Frontend (`ui`) | React, served by nginx | `2821` | `80` |
| Database (`postgres`) | PostgreSQL 15 | `7235` | `5432` |

The API waits for the Postgres healthcheck before starting, because Flyway applies database migrations at startup. CORS is set in `docker-compose.yml` to allow the UI on `http://localhost:2821` and the React dev server on `http://localhost:3000` (`npm start`).

## 🔍 Monitoring & Logging

Currently, logging can be accessed via Docker Desktop by selecting the relevant container.

## 📌 Future Considerations

- Hosting options (to be determined).
- External API integration for fixture/result data.
- Improved logging and monitoring.
- Security enhancements.

## 💜 License

This project is licensed under Кејн™.

