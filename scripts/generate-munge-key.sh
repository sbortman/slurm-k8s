#!/bin/bash
set -e

KEY_DIR=${1:-secrets}
KEY_PATH="$KEY_DIR/munge.key"

mkdir -p "$KEY_DIR"
dd if=/dev/urandom bs=1 count=1024 of="$KEY_PATH" status=none
chmod 600 "$KEY_PATH"
echo "MUNGE key created at: $KEY_PATH"
