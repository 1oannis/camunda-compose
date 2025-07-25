#!/bin/bash

# Camunda Platform Startup Script
# This script starts all Camunda Platform services with proper environment configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    echo "Camunda Platform Startup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -d, --detached Start services in detached mode (default)"
    echo "  -f, --follow   Start services and follow logs"
    echo "  -v, --verbose  Enable verbose output"
    echo ""
    echo "This script will:"
    echo "  - Load environment configuration files"
    echo "  - Start all Camunda Platform services"
    echo "  - Use hostname-specific configuration if available"
    echo ""
    echo "Environment files loaded:"
    echo "  - .env"
    echo "  - configuration/runtime.env"
    echo "  - configuration/runtime_local_\${HOSTNAME}.env"
    echo "  - configuration/runtime_local_\${HOSTNAME}/base-infrastructure.env"
    echo "  - configuration/runtime_local_\${HOSTNAME}/identity.env"
    echo "  - configuration/runtime_local_\${HOSTNAME}/core-services.env"
    echo "  - configuration/runtime_local_\${HOSTNAME}/web-modeler.env"
}

# Parse command line arguments
DETACHED=true
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--detached)
            DETACHED=true
            shift
            ;;
        -f|--follow)
            DETACHED=false
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if we're in the right directory
if [ ! -f "base-infrastructure.yaml" ]; then
    print_error "This script must be run from the camunda-compose-8.7 directory"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error "Environment file .env not found. Please copy env.sample to .env and configure it."
    exit 1
fi

# Validate environment files
HOSTNAME=${HOSTNAME:-SAMPLEHOST}
ENV_FILES=(
    ".env"
    "configuration/runtime.env"
    "configuration/runtime_local_${HOSTNAME}.env"
    "configuration/runtime_local_${HOSTNAME}/base-infrastructure.env"
    "configuration/runtime_local_${HOSTNAME}/identity.env"
    "configuration/runtime_local_${HOSTNAME}/core-services.env"
    "configuration/runtime_local_${HOSTNAME}/web-modeler.env"
)

print_status "Validating environment files..."
for env_file in "${ENV_FILES[@]}"; do
    if [ -f "$env_file" ]; then
        print_success "Found: $env_file"
    else
        print_warning "Missing: $env_file (will be included but may cause warnings)"
    fi
done

# Check if directories exist
print_status "Checking required directories..."
if [ ! -d "container.elasticsearch/data" ]; then
    print_warning "Elasticsearch data directory not found. Run ./directory_creation_util.sh first."
fi

if [ ! -d "container.postgres/data" ]; then
    print_warning "PostgreSQL data directory not found. Run ./directory_creation_util.sh first."
fi

# Build docker compose command with all environment files for all operations
COMPOSE_CMD="docker compose"
for env_file in "${ENV_FILES[@]}"; do
    COMPOSE_CMD="$COMPOSE_CMD --env-file $env_file"
done

if [ "$DETACHED" = true ]; then
    COMPOSE_CMD="$COMPOSE_CMD up -d"
    print_status "Starting Camunda Platform services in detached mode..."
else
    COMPOSE_CMD="$COMPOSE_CMD up"
    print_status "Starting Camunda Platform services (following logs)..."
fi

if [ "$VERBOSE" = true ]; then
    print_status "Verbose mode enabled"
    COMPOSE_CMD="$COMPOSE_CMD --verbose"
fi

# Execute the command (show full docker compose output)
print_status "Executing: $COMPOSE_CMD"
if eval "$COMPOSE_CMD"; then
    print_success "Camunda Platform services started successfully!"
    
    if [ "$DETACHED" = true ]; then
        print_status "Services are running in the background."
        print_status "To view logs: docker compose logs -f"
        print_status "To stop services: ./shutdown.sh"
    fi
else
    print_error "Failed to start Camunda Platform services"
    exit 1
fi
