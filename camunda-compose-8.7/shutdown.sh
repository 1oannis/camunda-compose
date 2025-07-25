#!/bin/bash

# Camunda Platform Shutdown Script
# This script stops all Camunda Platform services and removes volumes

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
    echo "Camunda Platform Shutdown Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --volumes  Remove volumes (default)"
    echo "  -k, --keep     Keep volumes (don't remove)"
    echo "  -f, --force    Force shutdown without confirmation"
    echo ""
    echo "This script will:"
    echo "  - Stop all Camunda Platform services"
    echo "  - Remove volumes by default (can be disabled)"
    echo "  - Use hostname-specific configuration if available"
    echo ""
    echo "Warning: Removing volumes will delete all data!"
    echo "Use --keep to preserve data for next startup."
}

# Parse command line arguments
REMOVE_VOLUMES=true
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--volumes)
            REMOVE_VOLUMES=true
            shift
            ;;
        -k|--keep)
            REMOVE_VOLUMES=false
            shift
            ;;
        -f|--force)
            FORCE=true
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

# Build docker compose command with all environment files for all operations
COMPOSE_CMD="docker compose"
for env_file in "${ENV_FILES[@]}"; do
    COMPOSE_CMD="$COMPOSE_CMD --env-file $env_file"
done

# Check if services are running (suppress output)
print_status "Checking if services are running..."
if ! eval "$COMPOSE_CMD ps --quiet" 2>/dev/null | grep -q .; then
    print_warning "No Camunda Platform services are currently running"
    exit 0
fi

# Ask for confirmation unless --force is used
if [ "$FORCE" = false ]; then
    echo ""
    if [ "$REMOVE_VOLUMES" = true ]; then
        print_warning "This will stop all services and REMOVE ALL DATA (volumes)!"
        echo ""
        echo "This action will delete:"
        echo "  - All database data (PostgreSQL, Elasticsearch)"
        echo "  - All Zeebe data"
        echo "  - All temporary files"
        echo ""
        echo "Configuration files and SSL certificates will be preserved."
        echo ""
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Shutdown cancelled"
            exit 0
        fi
    else
        print_status "This will stop all services but KEEP all data (volumes preserved)."
        echo ""
        read -p "Continue? (y/N): " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Shutdown cancelled"
            exit 0
        fi
    fi
fi





if [ "$REMOVE_VOLUMES" = true ]; then
    COMPOSE_CMD="$COMPOSE_CMD down -v"
    print_status "Stopping Camunda Platform services and removing volumes..."
else
    COMPOSE_CMD="$COMPOSE_CMD down"
    print_status "Stopping Camunda Platform services (keeping volumes)..."
fi

# Execute the command (show full docker compose output)
print_status "Executing: $COMPOSE_CMD"
if eval "$COMPOSE_CMD"; then
    print_success "Camunda Platform services stopped successfully!"
    
    if [ "$REMOVE_VOLUMES" = true ]; then
        print_warning "All data has been removed. You will need to reinitialize on next startup."
    else
        print_status "Data has been preserved. Services can be restarted with: ./startup.sh"
    fi
else
    print_error "Failed to stop Camunda Platform services"
    exit 1
fi
