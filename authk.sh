#!/bin/bash

AUTHORIZED_KEYS_FILE="~/.ssh/authorized_keys"

# Check if .ssh directory and authorized_keys file exist
ensure_ssh_setup() {
    if [ ! -d "/root/.ssh" ]; then
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
    fi

    if [ ! -f "$AUTHORIZED_KEYS_FILE" ]; then
        touch "$AUTHORIZED_KEYS_FILE"
        chmod 600 "$AUTHORIZED_KEYS_FILE"
    fi
}

# Add a key
add_key() {
    local public_key="$@"

    # Check if a key was provided
    if [ -z "$public_key" ]; then
        echo "Error: No public key provided."
        exit 1
    fi

    # Ensure .ssh and authorized_keys are set up
    ensure_ssh_setup

    # Check if the key already exists
    if grep -qxF "$public_key" "$AUTHORIZED_KEYS_FILE"; then
        echo "The key is already authorized."
    else
        echo "$public_key" >> "$AUTHORIZED_KEYS_FILE"
        echo "Key added successfully."
    fi
}

# List all keys
list_keys() {
    if [ ! -f "$AUTHORIZED_KEYS_FILE" ] || [ ! -s "$AUTHORIZED_KEYS_FILE" ]; then
        echo "No authorized keys found."
    else
        echo "Authorized keys:"
        cat "$AUTHORIZED_KEYS_FILE"
    fi
}

# Show help message
show_help() {
    echo "Usage: authk <command> [arguments]"
    echo
    echo "Commands:"
    echo "  add <public_key>    Add a new public key to authorized_keys."
    echo "  ls                  Show all authorized public keys."
    echo "  help                Show this help message."
}

# Main logic
case "$1" in
    add)
        shift
        add_key "$@"
        ;;
    ls)
        list_keys
        ;;
    help|*)
        show_help
        ;;
esac
