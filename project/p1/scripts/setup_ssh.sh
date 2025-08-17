#!/bin/bash

set -euo pipefail

PUBKEY_PATH="${1:?missing pubkey path}"

if [[ ! -f "$PUBKEY_PATH" ]]; then
	echo "Error: Public key file '$PUBKEY_PATH' not found."
	exit 1
fi

install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
install -m 600 -o vagrant -g vagrant "$PUBKEY_PATH" /home/vagrant/.ssh/authorized_keys
