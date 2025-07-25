#!/bin/bash

# Camunda Platform Compose Cleanup Script
# This script removes all data directories from containers while preserving configuration files and scripts

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

# Function to safely remove directory if it exists
safe_remove() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        print_status "Removing $description: $dir"
        rm -rf "$dir"
        print_success "Removed $description"
    else
        print_warning "$description does not exist: $dir"
    fi
}

# Main cleanup function
cleanup() {
    print_status "Starting Camunda Platform data cleanup..."
    
    # Stop all containers first to ensure data is not being written
    print_status "Stopping all containers..."
    ./shutdown.sh
    
    print_success "All containers stopped"
    
    # Remove data directories
    print_status "Removing data directories..."
    
    # Elasticsearch data
    safe_remove "./container.elasticsearch/data" "Elasticsearch data"
    
    # PostgreSQL data
    safe_remove "./container.postgres/data" "PostgreSQL data"
    
    # Zeebe data
    safe_remove "./container.zeebe/data" "Zeebe data"
    
    # Web Modeler database data
    safe_remove "./container.web-modeler-db/data" "Web Modeler database data"
    
    # Traefik certificates (preserved - not removing)
    print_status "Preserving Traefik certificates: ./container.traefik/letsencrypt"
    
    # Temporary directories
    safe_remove "./container.operate/tmp" "Operate temporary files"
    safe_remove "./container.tasklist/tmp" "Tasklist temporary files"
    
    print_success "Data cleanup completed!"
    
    # Show what was preserved
    print_status "Preserved configuration and scripts:"
    echo "  - container.elasticsearch/scripts/"
    echo "  - container.optimize/configuration/"
    echo "  - container.traefik/letsencrypt/"
    echo "  - All other configuration files"
    
    print_status "Cleanup completed successfully!"
    print_warning "Remember to restart your services with: ./startup.sh"
}

# Function to show help
show_help() {
    echo "Camunda Platform Compose Cleanup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --force    Force cleanup without confirmation"
    echo ""
    echo "This script will:"
    echo "  - Stop all running containers"
    echo "  - Remove all data directories"
    echo "  - Preserve configuration files and scripts"
    echo ""
    echo "Data directories that will be removed:"
    echo "  - container.elasticsearch/data/"
    echo "  - container.postgres/data/"
    echo "  - container.zeebe/data/"
    echo "  - container.web-modeler-db/data/"
    echo "  - container.operate/tmp/"
    echo "  - container.tasklist/tmp/"
    echo ""
    echo "Configuration files that will be preserved:"
    echo "  - container.elasticsearch/scripts/"
    echo "  - container.optimize/configuration/"
    echo "  - container.traefik/letsencrypt/"
    echo "  - All other configuration files"
}

# Parse command line arguments
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
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

# Ask for confirmation unless --force is used
if [ "$FORCE" = false ]; then
    echo ""
    print_warning "This will permanently delete all data from your Camunda Platform containers!"
    echo ""
    echo "The following data will be removed:"
    echo "  - All database data (PostgreSQL, Elasticsearch)"
    echo "  - All Zeebe data"
    echo "  - All temporary files"
    echo ""
    echo "Configuration files, scripts, and SSL certificates will be preserved."
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleanup cancelled"
        exit 0
    fi
fi

# Run the cleanup
cleanup 