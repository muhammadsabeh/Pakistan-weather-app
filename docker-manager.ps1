# Tic Tac Toe Docker Management Script (PowerShell)
# Usage: .\docker-manager.ps1 [command]

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

$COMPOSE_FILE = "docker-compose.yml"
$SERVICE_NAME = "tic-tac-toe"
$TEST_FILE = "test_app.py"

# Helper functions
function Write-Header {
    param([string]$Text)
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "✅ $Text" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "❌ $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ️  $Text" -ForegroundColor Yellow
}

# Commands
function Start-App {
    Write-Header "🚀 Starting Tic Tac Toe Application"
    docker compose -f $COMPOSE_FILE up -d
    Write-Success "Application started"
    Write-Info "Access at: http://localhost:5000"
    Start-Sleep -Seconds 3
    docker compose -f $COMPOSE_FILE ps
}

function Stop-App {
    Write-Header "⏹️  Stopping Tic Tac Toe Application"
    docker compose -f $COMPOSE_FILE down
    Write-Success "Application stopped"
}

function Restart-App {
    Write-Header "🔄 Restarting Tic Tac Toe Application"
    docker compose -f $COMPOSE_FILE restart $SERVICE_NAME
    Write-Success "Application restarted"
    Start-Sleep -Seconds 2
    docker compose -f $COMPOSE_FILE ps
}

function Show-Logs {
    Write-Header "📝 Application Logs"
    docker compose -f $COMPOSE_FILE logs -f --tail=50 $SERVICE_NAME
}

function Build-Image {
    Write-Header "🏗️  Building Docker Image"
    docker compose -f $COMPOSE_FILE build --no-cache
    Write-Success "Docker image built"
}

function Show-Status {
    Write-Header "📊 Service Status"
    docker compose -f $COMPOSE_FILE ps
}

function Clean-Up {
    Write-Header "🧹 Cleaning Up"
    docker compose -f $COMPOSE_FILE down -v
    Write-Success "Cleanup completed"
}

function Run-Tests {
    Write-Header "🧪 Running Automated Tests"
    
    # Check if service is running
    $status = docker compose -f $COMPOSE_FILE ps $SERVICE_NAME 2>&1
    if (-not ($status -match "running")) {
        Write-Info "Starting service for tests..."
        Start-App
    }
    
    # Install test dependencies
    Write-Info "Installing test dependencies..."
    python -m pip install -q requests
    
    # Run tests
    Write-Info "Running test suite..."
    python $TEST_FILE
    if ($LASTEXITCODE -eq 0) {
        Write-Success "All tests passed!"
    } else {
        Write-Error-Custom "Tests failed!"
        Write-Info "Showing application logs..."
        docker compose -f $COMPOSE_FILE logs $SERVICE_NAME
    }
}

function Open-Shell {
    Write-Header "🔧 Opening Container Shell"
    docker compose -f $COMPOSE_FILE exec $SERVICE_NAME /bin/bash
}

function Show-Stats {
    Write-Header "📈 Container Resource Usage"
    docker stats "$($SERVICE_NAME)-app"
}

function Show-Help {
    @"
═══════════════════════════════════════════════════════════
🎮 Tic Tac Toe - Docker Management Script (PowerShell)
═══════════════════════════════════════════════════════════

Usage: .\docker-manager.ps1 [command]

Commands:
  start       - Start the application
  stop        - Stop the application
  restart     - Restart the application
  logs        - View application logs
  build       - Build Docker image
  ps          - Show service status
  test        - Run automated tests
  shell       - Open container shell
  stats       - Show resource usage
  clean       - Remove all containers and volumes
  help        - Show this help message

Examples:
  .\docker-manager.ps1 start
  .\docker-manager.ps1 logs
  .\docker-manager.ps1 test
  .\docker-manager.ps1 stop

═══════════════════════════════════════════════════════════
"@ | Write-Host -ForegroundColor Cyan
}

# Main logic
switch ($Command.ToLower()) {
    "start" { Start-App }
    "stop" { Stop-App }
    "restart" { Restart-App }
    "logs" { Show-Logs }
    "build" { Build-Image }
    "ps" { Show-Status }
    "test" { Run-Tests }
    "shell" { Open-Shell }
    "stats" { Show-Stats }
    "clean" { Clean-Up }
    "help" { Show-Help }
    default {
        Write-Error-Custom "Unknown command: $Command`n"
        Show-Help
        exit 1
    }
}
