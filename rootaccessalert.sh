#!/bin/bash

# Configuration Options
LOG_FILE="/var/log/auth.log"
AUDIT_LOG="/var/log/audit/audit.log"
EMAIL="kzhongliang@hotmail.com"
LOG_MONITOR_LOG="/var/log/log_monitor.log"
LOG_ENTRY_PATTERN="ubuntu sudo: pam_unix(sudo:session): session opened for user root by (uid=0)"
SLEEP_INTERVAL=5

# Authorized auid values (add more as needed)
AUTHORIZED_AUID=(1000)

# Function to log messages with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_MONITOR_LOG"
}

# Ensure the log monitor log file exists
touch "$LOG_MONITOR_LOG"

echo "Monitoring $LOG_FILE for Root access. Notifications will be sent to $EMAIL."

# Set the initial line count to start monitoring
line_count=$(wc -l < "$LOG_FILE")

# Continuously monitor the log file
while true; do
    # Get the current line count
    current_count=$(wc -l < "$LOG_FILE")

    # Calculate the number of new lines
    lines_added=$((current_count - line_count))

    # Check if new lines have been added
    if [ "$lines_added" -gt 0 ]; then
        # Check the new lines for the specified log entry pattern
        tail -n "$lines_added" "$LOG_FILE" | grep -q "$LOG_ENTRY_PATTERN"

        if [ $? -eq 0 ]; then
            # Extract auid from the audit log
            auid=$(grep -oP 'auid=\K\d+' "$AUDIT_LOG" | tail -n 1)

            # Check if auid is in the authorized array
            authorized=false
            for auth_auid in "${AUTHORIZED_AUID[@]}"; do
                if [ "$auid" -eq "$auth_auid" ]; then
                    authorized=true
                    break
                fi
            done

            # Check if auid is not authorized
            if [ "$authorized" = false ]; then
                # Log entry found, send an email alert using ssmtp
                echo -e "To: $EMAIL\nSubject: Unauthorised Root Access Alert\n\nUnauthorised root access detected on $(hostname) at $(date) by auid=$auid. Contact admin immediately." | ssmtp "$EMAIL"
                log_message "Unauthorised root access detected. Email notification sent. (auid=$auid)"
            else
                log_message "Root access detected by authorized user (auid=$auid)."
            fi
        fi
    fi

    # Update the line count for the next iteration
    line_count="$current_count"

    # Sleep for a few seconds before checking again
    sleep "$SLEEP_INTERVAL"
done
