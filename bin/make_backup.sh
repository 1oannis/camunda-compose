#!/bin/bash

# Camunda Platform Backup Script
# This script creates backups of all container volumes and data directories

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
    echo "Camunda Platform Backup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -d, --destination    Backup destination directory (default: ./backups)"
    echo "  -n, --name           Custom backup name (default: auto-generated)"
    echo "  -f, --force          Force backup without stopping services"
    echo "  -q, --quick          Quick backup (skip service shutdown)"
    echo "  -v, --verbose        Enable verbose output"
    echo ""
    echo "This script will:"
    echo "  - Stop all Camunda Platform services (unless --quick is used)"
    echo "  - Create timestamped backup of all container data"
    echo "  - Include all container.* directories"
    echo "  - Restart services after backup (unless --quick is used)"
    echo ""
    echo "Backup includes:"
    echo "  - PostgreSQL data (container.postgres/data)"
    echo "  - Elasticsearch data (container.elasticsearch/data)"
    echo "  - Zeebe data (container.zeebe/data)"
    echo "  - All other container.* directories"
    echo ""
    echo "Backup location: ./backups/ (or specified destination)"
}

# Parse command line arguments
BACKUP_DEST="./backups"
BACKUP_NAME=""
FORCE=false
QUICK=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|--destination)
            BACKUP_DEST="$2"
            shift 2
            ;;
        -n|--name)
            BACKUP_NAME="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -q|--quick)
            QUICK=true
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

# Validate environment files
HOSTNAME=${HOSTNAME:-SAMPLEHOST}
ENV_FILES=(
    ".env"
    "configuration/runtime.env"
    "configuration/runtime_local_${HOSTNAME}.env"
    "configuration/runtime_local_${HOSTNAME}/reverse-proxy.env"
    "configuration/runtime_local_${HOSTNAME}/base-infrastructure.env"
    "configuration/runtime_local_${HOSTNAME}/identity.env"
    "configuration/runtime_local_${HOSTNAME}/core-services.env"
    "configuration/runtime_local_${HOSTNAME}/web-modeler.env"
)

# Build docker compose command with all environment files
COMPOSE_CMD="docker compose"
for env_file in "${ENV_FILES[@]}"; do
    COMPOSE_CMD="$COMPOSE_CMD --env-file $env_file"
done

# Generate backup name if not provided
if [ -z "$BACKUP_NAME" ]; then
    BACKUP_NAME="camunda-backup-$(date +%Y%m%d-%H%M%S)"
fi

# Create backup destination directory
mkdir -p "$BACKUP_DEST"

# Check if services are running
SERVICES_RUNNING=false
if eval "$COMPOSE_CMD ps --quiet" 2>/dev/null | grep -q .; then
    SERVICES_RUNNING=true
fi

# Handle service shutdown
if [ "$QUICK" = false ] && [ "$SERVICES_RUNNING" = true ]; then
    if [ "$FORCE" = false ]; then
        print_warning "Services are running. Stopping them for consistent backup..."
        echo ""
        read -p "Continue with service shutdown? (y/N): " -n 1 -r
        echo ""
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Backup cancelled"
            exit 0
        fi
    fi
    
    print_status "Stopping Camunda Platform services..."
    if ! eval "$COMPOSE_CMD down"; then
        print_error "Failed to stop services"
        exit 1
    fi
    print_success "Services stopped successfully"
fi

# Define container directories to backup
CONTAINER_DIRS=(
    "container.postgres"
    "container.elasticsearch"
    "container.zeebe"
    "container.operate"
    "container.tasklist"
    "container.optimize"
    "container.web-modeler-db"
    "container.traefik"
)

# Create backup archive
BACKUP_FILE="$BACKUP_DEST/${BACKUP_NAME}.tar.gz"
print_status "Creating backup: $BACKUP_FILE"

# Build tar command
TAR_CMD="tar -czf $BACKUP_FILE"

# Add container directories to backup
for dir in "${CONTAINER_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        TAR_CMD="$TAR_CMD $dir"
        print_status "Including: $dir"
    else
        print_warning "Directory not found: $dir"
    fi
done

# Add configuration files
TAR_CMD="$TAR_CMD configuration/"

# Add environment files
for env_file in "${ENV_FILES[@]}"; do
    if [ -f "$env_file" ]; then
        TAR_CMD="$TAR_CMD $env_file"
    fi
done

# Add compose files
TAR_CMD="$TAR_CMD *.yaml"

# Add backup metadata
echo "Backup created: $(date)" > backup-metadata.txt
echo "Backup name: $BACKUP_NAME" >> backup-metadata.txt
echo "Hostname: $HOSTNAME" >> backup-metadata.txt
echo "Services running during backup: $SERVICES_RUNNING" >> backup-metadata.txt
echo "Quick backup: $QUICK" >> backup-metadata.txt
echo "Container directories included:" >> backup-metadata.txt
for dir in "${CONTAINER_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  - $dir" >> backup-metadata.txt
    fi
done

TAR_CMD="$TAR_CMD backup-metadata.txt"

# Execute backup
print_status "Executing backup..."
if [ "$VERBOSE" = true ]; then
    print_status "Command: $TAR_CMD"
fi

if eval "$TAR_CMD"; then
    print_success "Backup created successfully!"
    print_status "Backup file: $BACKUP_FILE"
    
    # Show backup size
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    print_status "Backup size: $BACKUP_SIZE"
    
    # Clean up metadata file
    rm -f backup-metadata.txt
    
    # Restart services if they were running and not quick backup
    if [ "$QUICK" = false ] && [ "$SERVICES_RUNNING" = true ]; then
        print_status "Restarting Camunda Platform services..."
        if eval "$COMPOSE_CMD up -d"; then
            print_success "Services restarted successfully"
        else
            print_warning "Failed to restart services. Please start manually with: ./startup.sh"
        fi
    fi
    
    print_success "Backup completed successfully!"
    print_status "To restore this backup: ./restore_backup.sh $BACKUP_FILE"
    
else
    print_error "Backup failed"
    
    # Clean up failed backup file
    if [ -f "$BACKUP_FILE" ]; then
        rm -f "$BACKUP_FILE"
    fi
    
    # Restart services if they were stopped
    if [ "$QUICK" = false ] && [ "$SERVICES_RUNNING" = true ]; then
        print_status "Attempting to restart services..."
        eval "$COMPOSE_CMD up -d" || print_warning "Failed to restart services. Please start manually with: ./startup.sh"
    fi
    
    exit 1
fi 