#!/bin/bash

AUTHORIZED_KEYS_FILE="/root/.ssh/authorized_keys"

# 檢查 .ssh 目錄和 authorized_keys 文件是否存在
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

# 添加密鑰
add_key() {
    local public_key="$@"

    # 檢查是否提供了密鑰
    if [ -z "$public_key" ]; then
        echo "Error: No public key provided."
        exit 1
    fi

    # 確保 .ssh 和 authorized_keys 已設置
    ensure_ssh_setup

    # 檢查密鑰是否已存在
    if grep -qxF "$public_key" "$AUTHORIZED_KEYS_FILE"; then
        echo "The key is already authorized."
    else
        echo "$public_key" >> "$AUTHORIZED_KEYS_FILE"
        echo "Key added successfully."
    fi
}

# 列出所有密鑰
list_keys() {
    if [ ! -f "$AUTHORIZED_KEYS_FILE" ] || [ ! -s "$AUTHORIZED_KEYS_FILE" ]; then
        echo "No authorized keys found."
    else
        echo "Authorized keys:"
        cat "$AUTHORIZED_KEYS_FILE"
    fi
}

# 顯示幫助訊息
show_help() {
    echo "Usage: authk <command> [arguments]"
    echo
    echo "Commands:"
    echo "  add <public_key>    Add a new public key to authorized_keys."
    echo "  ls                  Show all authorized public keys."
    echo "  help                Show this help message."
}

# 主邏輯
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