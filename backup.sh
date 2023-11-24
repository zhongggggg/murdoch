#!/bin/bash

# Email settings for backup completion notification
recipient_email="kzhongliang@hotmail.com"
subject="Backup and checksum completion"

# Directories to backup (Add directories as necessary)
backup_directories="/root"

# Destination for backups
backup_destination="/home/roots/backup"

# Folder for storing checksums
hash_folder="/home/roots/hash"

# Create directories if they don't exist
create_folder_if_not_exists() {
  local folder="$1"
  if [ ! -d "$folder" ]; then
    mkdir -p "$folder"
  fi
}

create_folder_if_not_exists "$backup_destination"
create_folder_if_not_exists "$hash_folder"

# Create a timestamp for the backup
timestamp=$(date +"%Y-%m-%d_%H:%M:%S")

# Create a tarball with the backup
backup_filename="backup_$timestamp.tar.gz"
tar -czf "$backup_destination/$backup_filename" $backup_directories

# Calculate checksum and store in a separate folder with the backup name
checksum=$(sha256sum "$backup_destination/$backup_filename" | awk '{print $1}')
echo "$checksum" > "$hash_folder/$backup_filename.txt"

# Find and delete backups older than 7 days
find "$backup_destination" -name "backup_*.tar.gz" -type f -mtime +7 -exec rm {} \;

# Email notification
email_message="Backup for $backup_filename completed. Hash: $checksum"
echo -e "To: $recipient_email\nSubject: $subject\n\n$email_message" | ssmtp "$recipient_email"

# Print a message indicating the backup completion
echo "Backup completed: $backup_destination/$backup_filename"
echo "Checksum calculated and stored in $hash_folder/$backup_filename.txt"
echo "Email notification sent to $recipient_email"
