#!/bin/bash

# Script to restore a directory from backup and log the process

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 /path/to/backup/dir /path/to/original/location"
    exit 1
fi

# Assign arguments to variables
backup_dir="$1"
original_location="$2"

# Log file
log_file="/var/log/restore_log.txt"

# Check if the backup directory exists
if [ ! -d "$backup_dir" ]; then
    echo "Error: Backup directory not found." | tee -a "$log_file"
    exit 1
fi

# Check if the original location exists
if [ ! -d "$original_location" ]; then
    echo "Error: Original location not found." | tee -a "$log_file"
    exit 1
fi

# Ensure absolute paths
backup_dir=$(realpath "$backup_dir")
original_location=$(realpath "$original_location")

# Timestamp for the log entry
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Log the restoration process
echo "[$timestamp] Restoring $backup_dir to $original_location..." | tee -a "$log_file"

# Perform the restoration
rsync -a --delete "$backup_dir/" "$original_location/"

# Verify the restoration and log the files involved
echo "Verification:" | tee -a "$log_file"
ls -l "$original_location" | tee -a "$log_file"

# Log the completion message
echo "[$timestamp] Restoration completed successfully." | tee -a "$log_file"
