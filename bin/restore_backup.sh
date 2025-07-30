#!/bin/bash

# Camunda Platform Restore Script
# This script restores container volumes and data from a backup archive

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
    echo "Camunda Platform Restore Script"
    echo ""
    echo "Usage: $0 [OPTIONS] BACKUP_FILE"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -f, --force          Force restore without confirmation"
    echo "  -v, --verbose        Enable verbose output"
    echo "  -d, --dry-run        Show what would be restored (don't actually restore)"
    echo ""
    echo "Arguments:"
    echo "  BACKUP_FILE          Path to the backup archive (.tar.gz file)"
    echo ""
    echo "This script will:"
    echo "  - Stop all Camunda Platform services"
    echo "  - Extract backup archive"
    echo "  - Restore all container data directories"
    echo "  - Restart services after restore"
    echo ""
    echo "Warning: This will overwrite existing data!"
    echo "Use --dry-run to preview what will be restored."
}

# Parse command line arguments
FORCE=false
VERBOSE=false
DRY_RUN=false

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
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            BACKUP_FILE="$1"
            shift
            ;;
    esac
done

# Check if backup file is provided
if [ -z "$BACKUP_FILE" ]; then
    print_error "Backup file not specified"
    show_help
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "base-infrastructure.yaml" ]; then
    print_error "This script must be run from the camunda-compose-8.7 directory"
    exit 1
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    print_error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Validate backup file format
if [[ ! "$BACKUP_FILE" =~ \.tar\.gz$ ]]; then
    print_error "Backup file must be a .tar.gz archive"
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

# Extract backup metadata
print_status "Analyzing backup file..."
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

if ! tar -tzf "$BACKUP_FILE" > "$TEMP_DIR/contents.txt" 2>/dev/null; then
    print_error "Invalid backup archive or corrupted file"
    exit 1
fi

# Check for metadata file
if grep -q "backup-metadata.txt" "$TEMP_DIR/contents.txt"; then
    print_status "Found backup metadata, extracting..."
    tar -xzf "$BACKUP_FILE" backup-metadata.txt -O
    echo ""
fi

# Show backup contents
print_status "Backup contains:"
grep "^container\." "$TEMP_DIR/contents.txt" | head -10
if [ $(grep "^container\." "$TEMP_DIR/contents.txt" | wc -l) -gt 10 ]; then
    print_status "... and more container directories"
fi

# Check if services are running
SERVICES_RUNNING=false
if eval "$COMPOSE_CMD ps --quiet" 2>/dev/null | grep -q .; then
    SERVICES_RUNNING=true
fi

# Ask for confirmation unless --force is used
if [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
    echo ""
    print_warning "This will overwrite existing data and restart services!"
    echo ""
    echo "The following will be restored:"
    echo "  - All container.* directories"
    echo "  - Configuration files"
    echo "  - Environment files"
    echo ""
    if [ "$SERVICES_RUNNING" = true ]; then
        echo "Services will be stopped and restarted during restore."
    fi
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restore cancelled"
        exit 0
    fi
fi

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    print_status "DRY RUN MODE - No changes will be made"
    print_status "Backup file: $BACKUP_FILE"
    print_status "Services running: $SERVICES_RUNNING"
    print_status "Would restore the following:"
    
    # Show what would be overwritten vs extracted
    print_status "Would OVERWRITE these directories:"
    grep "^container\." "$TEMP_DIR/contents.txt" | head -10
    if [ $(grep "^container\." "$TEMP_DIR/contents.txt" | wc -l) -gt 10 ]; then
        print_status "... and more container directories"
    fi
    
    print_status "Would extract (but not overwrite):"
    grep -v "^container\." "$TEMP_DIR/contents.txt" | grep -v "backup-metadata.txt" | head -10
    if [ $(grep -v "^container\." "$TEMP_DIR/contents.txt" | grep -v "backup-metadata.txt" | wc -l) -gt 10 ]; then
        print_status "... and more configuration files"
    fi
    
    # Simulate change detection for dry run
    print_status "Would analyze changes in container directories:"
    for dir in container.*; do
        if [ -d "$dir" ]; then
            TOP_DIR_COUNT=$(find "$dir" -maxdepth 1 -type d 2>/dev/null | wc -l)
            FILE_COUNT=$(find "$dir" -type f 2>/dev/null | wc -l)
            print_status "  $dir: $TOP_DIR_COUNT top-level directories, $FILE_COUNT files would be compared"
            
            if [ "$VERBOSE" = true ]; then
                print_status "    Top-level directories in $dir:"
                find "$dir" -maxdepth 1 -type d | sort | while read -r subdir; do
                    if [ "$subdir" != "$dir" ]; then
                        SUB_FILE_COUNT=$(find "$subdir" -type f 2>/dev/null | wc -l)
                        echo "      $(basename "$subdir") ($SUB_FILE_COUNT files)"
                    fi
                done
            fi
        fi
    done
    
    exit 0
fi

# Stop services if running
if [ "$SERVICES_RUNNING" = true ]; then
    print_status "Stopping Camunda Platform services..."
    if ! eval "$COMPOSE_CMD down"; then
        print_error "Failed to stop services"
        exit 1
    fi
    print_success "Services stopped successfully"
fi

# Create backup of current state (safety measure)
CURRENT_BACKUP="./backups/pre-restore-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
print_status "Creating safety backup of current state: $CURRENT_BACKUP"
mkdir -p "./backups"

SAFETY_TAR_CMD="tar -czf $CURRENT_BACKUP"
for dir in container.*; do
    if [ -d "$dir" ]; then
        SAFETY_TAR_CMD="$SAFETY_TAR_CMD $dir"
    fi
done
eval "$SAFETY_TAR_CMD" || print_warning "Failed to create safety backup"

# Create state snapshot before restore for change detection
print_status "Creating state snapshot for change detection..."
TEMP_DIR_STATE=$(mktemp -d)
trap "rm -rf $TEMP_DIR $TEMP_DIR_STATE" EXIT

# Document current state of container directories
if [ "$VERBOSE" = true ]; then
    print_status "Documenting current state..."
fi

for dir in container.*; do
    if [ -d "$dir" ]; then
        if [ "$VERBOSE" = true ]; then
            print_status "Scanning: $dir"
        fi
        # Create directory structure snapshot instead of individual files
        find "$dir" -type d | sort > "$TEMP_DIR_STATE/before_${dir}_dirs.txt" || true
        find "$dir" -type f | wc -l > "$TEMP_DIR_STATE/before_${dir}_filecount.txt" || true
        # Store top-level subdirectories for comparison
        find "$dir" -maxdepth 1 -type d | sort > "$TEMP_DIR_STATE/before_${dir}_topdirs.txt" || true
    fi
done

# Extract backup
print_status "Extracting backup archive..."
if [ "$VERBOSE" = true ]; then
    tar -xzf "$BACKUP_FILE"
else
    tar -xzf "$BACKUP_FILE" 2>/dev/null
fi

if [ $? -eq 0 ]; then
    print_success "Backup extracted successfully"
else
    print_error "Failed to extract backup"
    exit 1
fi

# Document state after restore
print_status "Documenting restored state..."
for dir in container.*; do
    if [ -d "$dir" ]; then
        if [ "$VERBOSE" = true ]; then
            print_status "Scanning: $dir"
        fi
        # Create directory structure snapshot instead of individual files
        find "$dir" -type d | sort > "$TEMP_DIR_STATE/after_${dir}_dirs.txt" || true
        find "$dir" -type f | wc -l > "$TEMP_DIR_STATE/after_${dir}_filecount.txt" || true
        # Store top-level subdirectories for comparison
        find "$dir" -maxdepth 1 -type d | sort > "$TEMP_DIR_STATE/after_${dir}_topdirs.txt" || true
    fi
done

# Analyze changes
print_status "Analyzing changes..."
CHANGES_FOUND=false

for dir in container.*; do
    if [ -d "$dir" ] && [ -f "$TEMP_DIR_STATE/before_${dir}_topdirs.txt" ] && [ -f "$TEMP_DIR_STATE/after_${dir}_topdirs.txt" ]; then
        # Get file counts
        BEFORE_COUNT=$(cat "$TEMP_DIR_STATE/before_${dir}_filecount.txt" 2>/dev/null || echo "0")
        AFTER_COUNT=$(cat "$TEMP_DIR_STATE/after_${dir}_filecount.txt" 2>/dev/null || echo "0")
        
        # Compare top-level directory structures
        if ! cmp -s "$TEMP_DIR_STATE/before_${dir}_topdirs.txt" "$TEMP_DIR_STATE/after_${dir}_topdirs.txt"; then
            CHANGES_FOUND=true
            print_status "Changes detected in $dir:"
            print_status "  Files: $BEFORE_COUNT → $AFTER_COUNT"
            
            # Show added top-level directories
            diff "$TEMP_DIR_STATE/before_${dir}_topdirs.txt" "$TEMP_DIR_STATE/after_${dir}_topdirs.txt" | \
                grep "^>" | cut -c3- | \
                while read -r directory; do
                    echo "  + $directory"
                done
            
            # Show removed top-level directories
            diff "$TEMP_DIR_STATE/before_${dir}_topdirs.txt" "$TEMP_DIR_STATE/after_${dir}_topdirs.txt" | \
                grep "^<" | cut -c3- | \
                while read -r directory; do
                    echo "  - $directory"
                done
        else
            # Check if only file count changed (same structure, different files)
            if [ "$BEFORE_COUNT" != "$AFTER_COUNT" ]; then
                CHANGES_FOUND=true
                print_status "Changes detected in $dir:"
                print_status "  Files: $BEFORE_COUNT → $AFTER_COUNT (same directory structure)"
            elif [ "$VERBOSE" = true ]; then
                print_status "No changes detected in $dir"
            fi
        fi
    fi
done

if [ "$CHANGES_FOUND" = false ]; then
    print_warning "No changes detected - this may indicate the backup is identical to current state"
fi

# Verify critical directories were restored
CRITICAL_DIRS=("container.postgres" "container.elasticsearch" "container.zeebe")
MISSING_DIRS=()

for dir in "${CRITICAL_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        MISSING_DIRS+=("$dir")
    fi
done

if [ ${#MISSING_DIRS[@]} -gt 0 ]; then
    print_warning "Some critical directories are missing: ${MISSING_DIRS[*]}"
    print_warning "This may indicate an incomplete backup"
fi

# Restart services
print_status "Restarting Camunda Platform services..."
if eval "$COMPOSE_CMD up -d"; then
    print_success "Services restarted successfully"
else
    print_warning "Failed to restart services. Please start manually with: ./startup.sh"
fi

print_success "Restore completed successfully!"
print_status "Safety backup created: $CURRENT_BACKUP"
print_status "Services should now be running with restored data"

# Show service status
print_status "Checking service status..."
eval "$COMPOSE_CMD ps" 