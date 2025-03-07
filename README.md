# Tournament Prediction Deployment

This repository contains the deployment configuration for the **Tournament Prediction Application**. The application allows groups of users to compete in predicting scorelines for major international football tournaments such as the FIFA World Cup and the UEFA European Championships.

## 📦 Repository Structure

This repository is designed to work alongside the following sibling repositories:

- `tournament-prediction-api` (FastAPI backend)
- `tournament-prediction-ui` (React frontend)
- `tournament-prediction-deployment` (this repo, containing the deployment configuration)

## 🚀 Local Deployment

### Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your machine.
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
   ```
   *(These values are only relevant for local development so choose whatever you like.)*

4. Build and run the application:
   ```sh
   docker-compose up --build
   ```

5. Once running, the API documentation will be available at:
   - [Swagger UI](http://localhost:8000/docs)

## 🛠️ Services

The application is composed of the following services:

- **Backend**: FastAPI-based service running on port `8000`.
- **Frontend**: React-based UI running on port `3000`.
- **Database**: PostgreSQL instance running within a Docker container.

## 🔍 Monitoring & Logging

Currently, logging can be accessed via Docker Desktop by selecting the relevant container.

## 📌 Future Considerations

- Hosting options (to be determined).
- External API integration for fixture/result data.
- Improved logging and monitoring.
- Security enhancements.

## 💜 License

This project is licensed under Кејн™.

