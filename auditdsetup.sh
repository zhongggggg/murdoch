#!/bin/bash

# Set up audit rules
sudo auditctl -w /etc -p wa -k etc_changes
sudo auditctl -w /bin -p wa -k bin_changes
sudo auditctl -w /root -p wa -k root_changes

echo "Audit rules have been successfully setup."
