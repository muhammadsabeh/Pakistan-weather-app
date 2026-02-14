# 🐳 Tic Tac Toe - Docker Deployment Guide

## 📋 Overview

This directory contains complete Docker and Kubernetes configuration for the Tic Tac Toe application, along with a comprehensive CI/CD pipeline.

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- Python 3.11+ (for local testing)

### Start Application

```bash
# Navigate to project root
cd Pakistan-weather-app

# Start application with Docker Compose
docker compose up -d

# View logs
docker compose logs -f tic-tac-toe

# Access application
http://localhost:5000
```

### Stop Application

```bash
docker compose down
```

## 📁 Configuration Files

### `Dockerfile`
- **Base Image**: `python:3.11-slim`
- **Working Directory**: `/app`
- **Port**: 5000
- **Health Check**: Enabled (30s interval)
- **Environment**: Production

### `docker-compose.yml`
- **Service**: `tic-tac-toe`
- **Container Name**: `tic-tac-toe-app`
- **Port Mapping**: `5000:5000`
- **Restart Policy**: `unless-stopped`
- **Health Check**: Built-in
- **Network**: Bridge network for isolation

## 🧪 Testing

### Run Tests Locally

```bash
# Install test dependencies
pip install requests

# Start application
docker compose up -d

# Run test suite
python test_app.py

# Stop application
docker compose down
```

### Test Coverage

The automated test suite (`test_app.py`) includes:

1. **Home Page Test** - Verify HTML UI loads
2. **Get Board State** - Test API board endpoint
3. **Make Move** - Test player move and AI response
4. **Invalid Move** - Test error handling
5. **Reset Game** - Test game reset functionality
6. **Game Flow** - Test complete game sequence

All tests validate:
- ✅ HTTP status codes
- ✅ Response JSON structure
- ✅ Game logic correctness
- ✅ AI response validation

## 🔄 CI/CD Pipeline

### Pipeline Stages

The GitHub Actions pipeline (`.github/workflows/pipeline.yml`) includes three mandatory stages:

#### 1️⃣ Build Stage
- Builds Docker image
- Tags with Git SHA and `latest`
- Shows build logs
- Takes ~2-3 minutes

#### 2️⃣ Deploy Stage
- Builds Docker image for deployment
- Deploys with `docker compose up`
- Waits for service readiness
- Verifies deployment
- Shows deployment logs
- Takes ~1-2 minutes

#### 3️⃣ Test Stage
- Builds Docker image
- Starts application via Docker Compose
- Waits for service readiness
- Runs automated test suite
- Shows logs on failure
- Cleans up resources
- Takes ~2-3 minutes

### Pipeline Features

```
✅ Automatic triggers on:
   - Push to main/develop branches
   - Pull requests to main/develop
   - Changes to application code or Docker configs

✅ Deployment logs:
   - Docker Compose service status
   - Application startup logs
   - Service readiness verification

✅ Test validation:
   - All API endpoints tested
   - Game logic verified
   - Error handling confirmed
   - Pipeline fails if tests fail (mandatory)

✅ Cleanup:
   - Automatic resource cleanup
   - Services stopped after tests
   - No dangling containers
```

## 📊 Service Configuration

### Port Mapping
| Service | Internal | External |
|---------|----------|----------|
| Flask App | 5000 | 5000 |

### Environment Variables
```
FLASK_APP=tic_tac_toe.py
FLASK_ENV=production
```

### Restart Policy
- **Policy**: `unless-stopped`
- **Behavior**: Automatically restarts on failure, but not when manually stopped

### Health Check
- **Endpoint**: `/api/board`
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3
- **Start Period**: 40 seconds

## 🛠️ Docker Commands

### Build Image
```bash
docker build -t tic-tac-toe:latest ./weather_app
```

### Run Container
```bash
docker run -p 5000:5000 tic-tac-toe:latest
```

### View Logs
```bash
docker compose logs -f tic-tac-toe
```

### Check Status
```bash
docker compose ps
```

### Execute Commands in Container
```bash
docker compose exec tic-tac-toe python -c "import sys; print(sys.version)"
```

## 📈 Monitoring

### View Real-time Logs
```bash
docker compose logs -f --tail=50 tic-tac-toe
```

### Health Status
```bash
docker compose ps
# Look for "healthy" status
```

### Resource Usage
```bash
docker stats tic-tac-toe-app
```

## 🔐 Security Notes

- Flask runs in production mode (no debug)
- Uses slim Python image to reduce attack surface
- Health checks ensure only healthy containers receive traffic
- Network isolation with custom bridge network

## 📝 File Structure

```
Pakistan-weather-app/
├── docker-compose.yml          # Docker Compose config
├── test_app.py                 # Automated test suite
├── .github/
│   └── workflows/
│       └── pipeline.yml        # CI/CD pipeline
└── weather_app/
    ├── Dockerfile              # Docker image definition
    ├── .dockerignore          # Docker build context exclusions
    ├── tic_tac_toe.py         # Flask application
    ├── requirements.txt       # Python dependencies
    └── templates/
        └── tic_tac_toe.html   # Game UI
```

## 🐛 Troubleshooting

### Container Won't Start
```bash
# Check logs
docker compose logs tic-tac-toe

# Rebuild image
docker compose build --no-cache

# Restart
docker compose restart tic-tac-toe
```

### Port Already in Use
```bash
# Find process using port 5000
netstat -ano | findstr :5000  # Windows
lsof -i :5000                 # macOS/Linux

# Change port in docker-compose.yml
# Modify: ports: ["5001:5000"]
```

### Tests Fail
```bash
# Check if service is running
docker compose ps

# View application logs
docker compose logs tic-tac-toe

# Restart service
docker compose restart tic-tac-toe
```

## 📚 Related Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flask Documentation](https://flask.palletsprojects.com/)

## 📄 License

This project is part of the Pakistan Weather App project.

---

**Last Updated**: February 14, 2026
**Pipeline Status**: [![Tic Tac Toe CI/CD Pipeline](https://github.com/YOUR_USERNAME/Pakistan-weather-app/actions/workflows/pipeline.yml/badge.svg)](https://github.com/YOUR_USERNAME/Pakistan-weather-app/actions)
