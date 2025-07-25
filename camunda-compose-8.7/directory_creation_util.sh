#!/bin/bash

# Camunda Platform Directory Creation Utility
# This script creates necessary directories and sets proper permissions for Camunda Platform containers

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

# Function to create directory and set permissions
create_directory() {
    local dir="$1"
    local owner="$2"
    local perms="$3"
    local description="$4"
    
    if [ ! -d "$dir" ]; then
        print_status "Creating $description directory: $dir"
        sudo mkdir -p "$dir"
        print_success "Created $description directory"
    else
        print_warning "$description directory already exists: $dir"
    fi
    
    print_status "Setting permissions for $description directory..."
    sudo chown "$owner" -R "$dir"
    sudo chmod "$perms" -R "$dir"
    print_success "Set permissions for $description directory"
}

# Function to show help
show_help() {
    echo "Camunda Platform Directory Creation Utility"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --force    Force recreation of directories (removes existing)"
    echo ""
    echo "This script will:"
    echo "  - Create all necessary directories for Camunda Platform containers"
    echo "  - Set proper ownership and permissions for each directory"
    echo "  - Ensure containers can access their required directories"
    echo ""
    echo "Directories that will be created:"
    echo "  - container.traefik/letsencrypt/ (SSL certificates)"
    echo "  - container.elasticsearch/data/ (Elasticsearch data)"
    echo "  - container.postgres/data/ (PostgreSQL data)"
    echo "  - container.zeebe/data/ (Zeebe data)"
    echo "  - container.operate/tmp/ (Operate temporary files)"
    echo "  - container.tasklist/tmp/ (Tasklist temporary files)"
    echo "  - container.web-modeler-db/data/ (Web Modeler database)"
    echo "  - container.optimize/configuration/ (Optimize configuration)"
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

print_status "Starting Camunda Platform directory creation..."
echo "--------------------------------"

# Create all directories with proper permissions
create_directory "./container.traefik/letsencrypt" "0:0" "600" "Traefik SSL certificates"
create_directory "./container.elasticsearch/data" "1000:0" "700" "Elasticsearch data"
create_directory "./container.postgres/data" "0:0" "755" "PostgreSQL data"
create_directory "./container.zeebe/data" "1001:1001" "700" "Zeebe data"
create_directory "./container.operate/tmp" "1001:1001" "700" "Operate temporary files"
create_directory "./container.tasklist/tmp" "1001:1001" "700" "Tasklist temporary files"
create_directory "./container.web-modeler-db/data" "0:0" "755" "Web Modeler database"
create_directory "./container.optimize/configuration" "1001:1001" "600" "Optimize configuration"

print_success "All directories created and permissions set successfully!"
print_status "You can now start the services with: ./startup.sh"
echo "--------------------------------"