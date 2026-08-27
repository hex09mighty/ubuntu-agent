#!/bin/bash

# Use 1st argument if provided; default to "agent01"
AGENT_NAME="${1:-agent01}"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

if ! id "$AGENT_NAME" &>/dev/null; then
    echo "Error: User '$AGENT_NAME' does not exist on this machine."
    exit 1
fi

echo "Patching session to force X11 for user: $AGENT_NAME..."

mkdir -p /var/lib/AccountsService/users

cat <<EOF > "/var/lib/AccountsService/users/$AGENT_NAME"
[User]
Session=ubuntu-xorg
XSession=ubuntu-xorg
SystemAccount=false
EOF

chmod 600 "/var/lib/AccountsService/users/$AGENT_NAME"

echo "✔ Successfully configured $AGENT_NAME to force X11 on login."
