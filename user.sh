#!/bin/bash
# filepath: c:\Users\paul2\Documents\github\Workspace-in-Docker\user.sh

# Usage:
# ./user.sh add <username> - Add a user with sudo privileges and set DOCKER_HOST
# ./user.sh ls            - List all users on the system

# Function to add a user
add_user() {
    USERNAME=$1

    if [ -z "$USERNAME" ]; then
        echo "Error: No username provided."
        echo "Usage: $0 add <username>"
        exit 1
    fi

    # Create the user if it doesn't already exist
    if id "$USERNAME" &>/dev/null; then
        echo "User '$USERNAME' already exists."
    else
        echo "Creating user '$USERNAME'..."
        useradd -m -s /bin/bash "$USERNAME"
        echo "User '$USERNAME' created successfully."
    fi

    # Add the user to sudoers with no password requirement
    if ! grep -q "^$USERNAME ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        echo "Adding '$USERNAME' to sudoers with no password requirement..."
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
        echo "User '$USERNAME' added to sudoers."
    else
        echo "User '$USERNAME' is already in sudoers."
    fi

    # Set DOCKER_HOST in the user's .bashrc
    BASHRC="/home/$USERNAME/.bashrc"
    if ! grep -q "export DOCKER_HOST=tcp://host.docker.internal:2375" "$BASHRC"; then
        echo "Setting DOCKER_HOST in $USERNAME's .bashrc..."
        echo 'export DOCKER_HOST=tcp://host.docker.internal:2375' >> "$BASHRC"
        echo "DOCKER_HOST set successfully."
    else
        echo "DOCKER_HOST is already set in $USERNAME's .bashrc."
    fi

    echo "User '$USERNAME' setup completed."
}

# Function to list all users
list_users() {
    echo "Listing all users on the system:"
    cut -d: -f1 /etc/passwd
}

# Main script logic
if [ "$1" == "add" ]; then
    add_user "$2"
elif [ "$1" == "ls" ]; then
    list_users
else
    echo "Usage:"
    echo "  $0 add <username> - Add a user with sudo privileges and set DOCKER_HOST"
    echo "  $0 ls            - List all users on the system"
    exit 1
fi