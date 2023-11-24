----- Incident Response Plan -----

This incident response plan serves as a framework to facilitate a swift and
coordinated response in the event of a system breach.

This plan was developed in accordance with the NIST Incident Response framework.

======================================================================================

1. Containment

        - Disconnect system from network                | sudo nmcli networking off
        - Review Active Users                           | who , w , last
        - Terminate Malicious User Session & Processes  | pkill -TERM -u <username>
        - Lock Malicious User account                   | sudo chage -E 0 <username>

2. Eradication

        - Review Monitor logs                           | cat /var/log/log_monitor.log

        - Review Auditd logs
                - /etc directory        | ausearch -k etc_changes -ts <time> -te <time>
                - /bin directory        | ausearch -k bin_changes -ts <time> -te <time>
                - /root directory       | ausearch -k root_changes -ts <time> -te <time> | grep -u

3. Recovery

        - Locate Backup to restore system                       | ls /home/roots/backup

        - Check integrity of backup file
                - Check hash of desired backup file             | sha256sum <filename>
                - Cross reference hash from stored hashes/email | ls /home/roots/hash

        - Restoration of backup file
                - Extract File          | sudo tar -xf <backup> -C <location>
                - Restore backup        | sudo ./restore.sh <backup> <location>

        - Remediation / Patching
                - Apply and validate patches, ensuring all systems are running the
                  latest stable software versions.

                - Change Passwords and Access credentials
