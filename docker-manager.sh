#!/bin/bash

# Tic Tac Toe Docker Management Script
# Usage: ./docker-manager.sh [command]

set -e

COMPOSE_FILE="docker-compose.yml"
SERVICE_NAME="tic-tac-toe"
TEST_FILE="test_app.py"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Commands
cmd_start() {
    print_header "Starting Tic Tac Toe Application"
    docker compose -f "$COMPOSE_FILE" up -d
    print_success "Application started"
    print_info "Access at: http://localhost:5000"
    sleep 3
    docker compose -f "$COMPOSE_FILE" ps
}

cmd_stop() {
    print_header "Stopping Tic Tac Toe Application"
    docker compose -f "$COMPOSE_FILE" down
    print_success "Application stopped"
}

cmd_restart() {
    print_header "Restarting Tic Tac Toe Application"
    docker compose -f "$COMPOSE_FILE" restart "$SERVICE_NAME"
    print_success "Application restarted"
    sleep 2
    docker compose -f "$COMPOSE_FILE" ps
}

cmd_logs() {
    print_header "Application Logs"
    docker compose -f "$COMPOSE_FILE" logs -f --tail=50 "$SERVICE_NAME"
}

cmd_build() {
    print_header "Building Docker Image"
    docker compose -f "$COMPOSE_FILE" build --no-cache
    print_success "Docker image built"
}

cmd_ps() {
    print_header "Service Status"
    docker compose -f "$COMPOSE_FILE" ps
}

cmd_clean() {
    print_header "Cleaning Up"
    docker compose -f "$COMPOSE_FILE" down -v
    print_success "Cleanup completed"
}

cmd_test() {
    print_header "Running Automated Tests"
    
    # Check if service is running
    if ! docker compose -f "$COMPOSE_FILE" ps "$SERVICE_NAME" | grep -q running; then
        print_info "Starting service for tests..."
        cmd_start
    fi
    
    # Install test dependencies
    print_info "Installing test dependencies..."
    python -m pip install -q requests
    
    # Run tests
    print_info "Running test suite..."
    if python "$TEST_FILE"; then
        print_success "All tests passed!"
        return 0
    else
        print_error "Tests failed!"
        print_info "Showing application logs..."
        docker compose -f "$COMPOSE_FILE" logs "$SERVICE_NAME"
        return 1
    fi
}

cmd_shell() {
    print_header "Opening Container Shell"
    docker compose -f "$COMPOSE_FILE" exec "$SERVICE_NAME" /bin/bash
}

cmd_stats() {
    print_header "Container Resource Usage"
    docker stats "$SERVICE_NAME-app"
}

cmd_help() {
    cat << EOF
${BLUE}═══════════════════════════════════════════════════════════${NC}
🎮 Tic Tac Toe - Docker Management Script
${BLUE}═══════════════════════════════════════════════════════════${NC}

Usage: ./docker-manager.sh [command]

Commands:
  ${GREEN}start${NC}       - Start the application
  ${GREEN}stop${NC}        - Stop the application
  ${GREEN}restart${NC}     - Restart the application
  ${GREEN}logs${NC}        - View application logs
  ${GREEN}build${NC}       - Build Docker image
  ${GREEN}ps${NC}          - Show service status
  ${GREEN}test${NC}        - Run automated tests
  ${GREEN}shell${NC}       - Open container shell
  ${GREEN}stats${NC}       - Show resource usage
  ${GREEN}clean${NC}       - Remove all containers and volumes
  ${GREEN}help${NC}        - Show this help message

Examples:
  ./docker-manager.sh start
  ./docker-manager.sh logs
  ./docker-manager.sh test
  ./docker-manager.sh stop

${BLUE}═══════════════════════════════════════════════════════════${NC}
EOF
}

# Main logic
case "${1:-help}" in
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    logs)
        cmd_logs
        ;;
    build)
        cmd_build
        ;;
    ps)
        cmd_ps
        ;;
    test)
        cmd_test
        ;;
    shell)
        cmd_shell
        ;;
    stats)
        cmd_stats
        ;;
    clean)
        cmd_clean
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        print_error "Unknown command: $1"
        cmd_help
        exit 1
        ;;
esac
