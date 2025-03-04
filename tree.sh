#!/bin/bash

source vars.cfg

# Set the cache directory base path
CACHE_DIR=${CACHE_DIR:-"/tmp"}  # Default to /tmp if CACHE_DIR is not set
BASE_DIR="$CACHE_DIR/nfs_stats"

# Ensure base directory exists
mkdir -p "$BASE_DIR"

# Function to generate random alphanumeric string
random_string() {
    # tr -dc A-Za-z0-9 </dev/urandom | head -c 6
    cat /dev/urandom | base64 | tr -dc '0-9a-zA-Z' | head -c6
}

# Function to generate directory tree
generate_tree() {
    local base_dir=$1
    local num_top=$2
    local num_scans=$3
    local num_files=$4
    local file_size_kb=$5

    for ((i = 1; i <= num_top; i++)); do
        # TIMESTAMP=$(date +%Y%m%d%S%N | cut -c1-14)  # Get YYYYmmddssmmmm
        TIMESTAMP=$(date +%Y%m%d%S%M | cut -c1-14)  # Get YYYYmmddssmmmm
        DIR_NAME="$(random_string)_$TIMESTAMP"
        FIRST_LEVEL_DIR="$base_dir/$DIR_NAME"
        
        # Create first-level directory
        echo "$i -- $FIRST_LEVEL_DIR"
        mkdir -p "$FIRST_LEVEL_DIR/SCANS"
        
        # Create SCANS subdirectories
        for ((j = 1; j <= num_scans; j++)); do
            SCAN_DIR="$FIRST_LEVEL_DIR/SCANS/$j/DICOM"
            mkdir -p "$SCAN_DIR"
            
            # Create files inside each DICOM directory
            for ((k = 1; k <= num_files; k++)); do
                dd if=/dev/urandom of="$SCAN_DIR/$k.dcm" bs=1024 count=$file_size_kb status=none
            done
        done
    done
}

# Call function with default values
generate_tree "$BASE_DIR/find" 100 10 1 1
generate_tree "$BASE_DIR/rsync/source1" 10 10 10 100

# Copy rsync/source1 to multiple destinations for multithread
for ((i = 2; i <= 5; i++)); do
   cp -r $BASE_DIR/rsync/source1 $BASE_DIR/rsync/source$i
done

echo "Directory tree successfully created in $BASE_DIR"

