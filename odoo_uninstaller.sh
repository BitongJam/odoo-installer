#!/bin/bash

# Define the project name variable correctly
project_name="odooV14sample"

# Print the project name to verify it's set correctly
echo "Project Name: $project_name"

# Disable the service
echo "Disabling service: $project_name.service"
sudo systemctl disable "$project_name.service"

# Stop the service if it's running
echo "Stopping service: $project_name.service"
sudo systemctl stop "$project_name.service"

# Remove the project directory
echo "Removing directory: /opt/$project_name"
sudo rm -rf "/opt/$project_name"

# Remove the log directory
echo "Removing log directory: /var/log/$project_name"
sudo rm -rf "/var/log/$project_name"

# Remove the service file
echo "Removing service file: /etc/systemd/system/$project_name.service"
sudo rm "/etc/systemd/system/$project_name.service"

# Reload the systemd daemon to apply changes
echo "Reloading systemd daemon"
sudo systemctl daemon-reload

# Remove the user created during the installation
echo "Removing user: $project_name"
sudo userdel -r "$project_name"

# Print a message indicating completion
echo "Uninstallation of $project_name completed."

