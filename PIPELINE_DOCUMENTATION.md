# 🔄 CI/CD Pipeline Documentation

## Overview

The Tic Tac Toe application includes a comprehensive GitHub Actions CI/CD pipeline that automatically builds, deploys, and tests the application on every push and pull request.

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Git Event Triggered                   │
│         (Push to main/develop or Pull Request)          │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
    ┌────▼──────┐         ┌──────▼────┐
    │ Linting   │         │ Unit Tests │
    │ (Optional)│         │ (Optional) │
    └────┬──────┘         └──────┬────┘
         │                       │
         └───────────┬───────────┘
                     │
         ┌───────────▼───────────┐
         │   Build Docker Image  │
         │  • Docker buildx      │
         │  • Tag with SHA + tag │
         │  • Display logs       │
         └───────────┬───────────┘
                     │
         ┌───────────▼──────────────┐
         │  Deploy with Compose     │
         │  • Build image           │
         │  • docker compose up -d  │
         │  • Wait for readiness    │
         │  • Show deployment logs  │
         └───────────┬──────────────┘
                     │
         ┌───────────▼──────────────────┐
         │  Run Automated Tests         │
         │  • Start application         │
         │  • Run test suite (test_app) │
         │  • Verify API endpoints      │
         │  • Test game logic           │
         │  • Cleanup on complete       │
         └───────────┬──────────────────┘
                     │
         ┌───────────▼──────────────────┐
         │  Pipeline Summary            │
         │  • Report status             │
         │  • Fail if any stage fails   │
         └──────────────────────────────┘
```

## Stages in Detail

### 🏗️ Build Stage

**Job Name**: `build`  
**Runner**: `ubuntu-latest`  
**Duration**: ~2-3 minutes

#### Steps:

1. **Checkout Code**
   - Uses GitHub Actions checkout@v3
   - Gets the latest code from the branch

2. **Set up Docker Buildx**
   - Enables advanced Docker build capabilities
   - Allows multi-platform builds (optional)

3. **Build Docker Image**
   ```bash
   docker build -t tic-tac-toe:${{ github.sha }} ./weather_app
   docker build -t tic-tac-toe:latest ./weather_app
   ```
   - Tags image with commit SHA
   - Tags image with `latest`
   - Uses optimized slim Python base image

4. **Show Build Logs**
   - Displays Docker images created
   - Verifies build success

#### Build Logs Output:
```
🔨 Building Docker image...
[+] Building 45.2s (11/11) FINISHED
 => [1/7] FROM python:3.11-slim
 => [2/7] WORKDIR /app
 => [3/7] COPY requirements.txt .
 => [4/7] RUN pip install...
 => [5/7] COPY tic_tac_toe.py .
 => [6/7] COPY templates/...
 => [7/7] RUN healthcheck...
✅ Docker image built successfully

REPOSITORY         TAG                    IMAGE ID
tic-tac-toe       ${{ github.sha }}      abc123def456
tic-tac-toe       latest                 abc123def456
```

---

### 🚀 Deploy Stage

**Job Name**: `deploy`  
**Runner**: `ubuntu-latest`  
**Requires**: `build` job success  
**Duration**: ~1-2 minutes

#### Steps:

1. **Checkout Code**
   - Gets the latest code

2. **Build Docker Image**
   - Rebuilds image for deployment
   - Uses fresh build for consistency

3. **Deploy with Docker Compose**
   ```bash
   docker compose up -d
   ```
   - Configuration:
     - Service name: `tic-tac-toe`
     - Container name: `tic-tac-toe-app`
     - Port: `5000:5000`
     - Restart: `unless-stopped`
     - Network: `tic-tac-toe-network`

4. **Show Deployment Logs**
   ```
   📊 Docker Compose Services Status:
   NAME                    STATUS
   tic-tac-toe-app         Up 2 seconds (healthy)
   
   📝 Application Logs:
   * Running on http://0.0.0.0:5000
   * WARNING: This is a development server...
   ```

5. **Wait for Service Readiness**
   ```bash
   # Tests health endpoint every 2 seconds
   # Retries 30 times (60 seconds total)
   docker compose exec -T tic-tac-toe curl -s http://localhost:5000/api/board
   ```
   - Polls `/api/board` endpoint
   - Waits until service responds
   - Ensures healthy startup

6. **Verify Deployment**
   - Confirms service is running
   - Shows final status

#### Deployment Logs Output:
```
📦 Starting deployment with Docker Compose...
Creating network "tic-tac-toe-network"...
Creating tic-tac-toe-app... done
⏳ Waiting for application to start...
Attempt 1/30: Waiting for service...
Attempt 2/30: Waiting for service...
Attempt 3/30: Waiting for service...
✅ Application is ready!
✅ Deployment completed
```

---

### 🧪 Test Stage

**Job Name**: `test`  
**Runner**: `ubuntu-latest`  
**Requires**: `deploy` job success  
**Duration**: ~2-3 minutes

#### Steps:

1. **Checkout Code**
   - Gets the latest code

2. **Build Docker Image**
   - Rebuilds for test environment

3. **Start Application**
   ```bash
   docker compose up -d
   ```

4. **Wait for Service**
   - Same as Deploy stage
   - Ensures service is ready before testing

5. **Set up Python**
   - Configures Python 3.11
   - Required for test script execution

6. **Install Test Dependencies**
   ```bash
   pip install requests
   ```

7. **Run Automated Tests**
   ```bash
   python test_app.py
   ```
   
   **Tests Performed:**
   
   | # | Test | What It Checks |
   |---|------|-----------------|
   | 1 | Home Page Load | HTML UI loads correctly |
   | 2 | Get Board State | API returns valid board |
   | 3 | Make a Move | Player move and AI response |
   | 4 | Invalid Move | Error handling for occupied cells |
   | 5 | Reset Game | Game reset functionality |
   | 6 | Game Flow | Complete game sequence works |

8. **Show Application Logs (on failure)**
   ```bash
   docker compose logs tic-tac-toe
   ```
   - Only displayed if tests fail
   - Helps with debugging

9. **Cleanup**
   ```bash
   docker compose down
   ```
   - Removes containers and networks
   - Frees up resources
   - Runs even if tests fail

#### Test Output Examples:

**✅ All Tests Passed:**
```
╭──────────────────────────────────────────────────────────╮
│      🎮 TIC TAC TOE - AUTOMATED TEST SUITE              │
╰──────────────────────────────────────────────────────────╯

⏳ Waiting for service to be ready...
✅ Service is ready!

🧪 TEST 1: Get Board State
   ✅ PASSED: Board retrieved successfully

🧪 TEST 2: Home Page Load
   ✅ PASSED: Home page loaded successfully

🧪 TEST 3: Make a Move (Human)
   ✅ PASSED: Move successful, board state: ['', '', 'X', ...]

🧪 TEST 4: Invalid Move (Occupied Cell)
   ✅ PASSED: Invalid move correctly rejected

🧪 TEST 5: Reset Game
   ✅ PASSED: Game reset successfully

🧪 TEST 6: Complete Game Flow
   ✅ PASSED: Game flow works correctly

═══════════════════════════════════════════════════════════
📊 TEST SUMMARY
═══════════════════════════════════════════════════════════
Passed: 6/6
✅ ALL TESTS PASSED!
```

**❌ Test Failed:**
```
🧪 TEST 3: Make a Move (Human)
   ❌ FAILED: AssertionError: Move should be successful

═══════════════════════════════════════════════════════════
📝 Application logs:
[error] Connection refused
[error] Flask startup error
```

---

### 📊 Summary Stage

**Job Name**: `summary`  
**Runner**: `ubuntu-latest`  
**Requires**: All stages (build, deploy, test)  
**Condition**: Always runs (even if previous jobs fail)

#### Output:
```
═══════════════════════════════════════════════════════════
🎮 TIC TAC TOE - CI/CD PIPELINE SUMMARY
═══════════════════════════════════════════════════════════

📦 Build Stage: success
🚀 Deploy Stage: success
🧪 Test Stage: success

✅ PIPELINE SUCCESS - All stages passed!
═══════════════════════════════════════════════════════════
```

## Trigger Configuration

### Automatic Triggers

The pipeline runs automatically on:

1. **Push Events**
   ```yaml
   on:
     push:
       branches: [main, develop]
       paths:
         - 'weather_app/**'
         - 'docker-compose.yml'
         - '.github/workflows/pipeline.yml'
   ```

2. **Pull Request Events**
   ```yaml
   on:
     pull_request:
       branches: [main, develop]
   ```

### Manual Trigger (Optional Configuration)

To enable manual triggering, add to `.github/workflows/pipeline.yml`:
```yaml
on:
  workflow_dispatch:
```

## Pipeline Behavior

### Success Scenario
```
✅ All stages pass
→ Code is merged automatically (with branch protection)
→ Deployment is ready for production
```

### Failure Scenario
```
❌ Any stage fails
→ Pipeline stops at that stage
→ Subsequent stages are skipped
→ Logs are shown for debugging
→ Owner is notified via GitHub
→ Code review is required to fix
```

## Key Features

✅ **Mandatory Testing**
- Pipeline fails if any test fails
- Prevents broken code from merging

✅ **Deployment Logs**
- Full Docker Compose logs displayed
- Service status shown
- Application startup verified

✅ **Resource Cleanup**
- Automatic cleanup after tests
- No dangling containers
- Network removed

✅ **Health Checks**
- Service readiness verified
- Health endpoint monitored
- Automatic retries on failure

✅ **Failure Reporting**
- Full logs on failure
- Application logs captured
- Easy debugging

## Accessing Pipeline Results

### GitHub Dashboard
1. Go to repository → Actions tab
2. Select workflow "Tic Tac Toe CI/CD Pipeline"
3. Click on specific run
4. View logs for each job

### Build Artifacts
```
Artifacts (if configured):
- Docker image (tic-tac-toe:latest)
- Test reports
- Deployment logs
```

## Performance

| Stage | Duration | Resources |
|-------|----------|-----------|
| Build | 2-3 min | 2 CPU cores, 7GB RAM |
| Deploy | 1-2 min | 2 CPU cores, 7GB RAM |
| Test | 2-3 min | 2 CPU cores, 7GB RAM |
| **Total** | **5-8 min** | - |

## Environment Details

- **OS**: Ubuntu 22.04 LTS
- **Docker**: 24.x
- **Python**: 3.11
- **Node**: Not required

## Extending the Pipeline

### Add More Tests
Edit `test_app.py`:
```python
def test_new_feature():
    """Test new endpoint"""
    # Add test code
    pass
```

### Add Linting Stage
Add to `.github/workflows/pipeline.yml`:
```yaml
lint:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    - run: pip install pylint
    - run: pylint weather_app/*.py
```

### Add Code Coverage
```yaml
- run: pip install coverage
- run: coverage run -m pytest
- run: coverage report
```

## Troubleshooting

### Pipeline Fails on Deploy
```
❌ Error: Connection refused
→ Check docker-compose.yml syntax
→ Verify Dockerfile is valid
→ Check port 5000 is available
```

### Tests Timeout
```
❌ Error: Service not ready after retries
→ Application might be crashing
→ Check application logs
→ Increase wait time in deploy step
```

### Cleanup Fails
```
❌ Error: Cannot find container
→ Container already stopped
→ Network already removed
→ Safe to ignore
```

## Best Practices

1. **Keep builds fast**
   - Use `.dockerignore`
   - Cache layers
   - Minimal base image

2. **Comprehensive tests**
   - Test all endpoints
   - Test error cases
   - Test game logic

3. **Clear logs**
   - Log important steps
   - Show progress
   - Help with debugging

4. **Resource management**
   - Always cleanup
   - Remove containers
   - Free up networks

5. **Documentation**
   - Document changes
   - Update README
   - Add comments to pipeline

---

**Last Updated**: February 14, 2026  
**Pipeline Version**: 1.0  
**Status**: Production Ready ✅
