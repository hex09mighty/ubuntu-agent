#!/bin/bash

# -------------------------------
# CONFIG
# -------------------------------
AGENT_NAME="agent01"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root (sudo)"
  exit 1
fi

echo "----------------------------------------"
echo "Setting up Restricted Agent Environment"
echo "----------------------------------------"

# -------------------------------
# 1. CREATE USER (NORMAL SHELL)
# -------------------------------
if id "$AGENT_NAME" &>/dev/null; then
  echo "User $AGENT_NAME already exists"
else
  useradd -m -s /bin/bash "$AGENT_NAME"
  echo "Set password for $AGENT_NAME"
  passwd "$AGENT_NAME"
fi

# -------------------------------
# 2. REMOVE ADMIN ACCESS
# -------------------------------
echo "Removing sudo access..."
deluser "$AGENT_NAME" sudo 2>/dev/null

# -------------------------------
# 3. ALLOW VPN / WIFI (POLKIT)
# -------------------------------
echo "Configuring VPN permissions..."

POLKIT_FILE="/etc/polkit-1/rules.d/50-agent-network.rules"

cat <<EOF > $POLKIT_FILE
polkit.addRule(function(action, subject) {
    if (
        subject.user == "$AGENT_NAME" &&
        action.id.indexOf("org.freedesktop.NetworkManager") == 0
    ) {
        return polkit.Result.YES;
    }
});
EOF

chmod 644 $POLKIT_FILE

# -------------------------------
# 4. BLOCK TERMINAL & APP CENTER
# -------------------------------
echo "Blocking Terminal and Software Center access..."

# Terminal
if [ -f /usr/bin/gnome-terminal ]; then
  chmod 750 /usr/bin/gnome-terminal
  chown root:root /usr/bin/gnome-terminal
fi

# GNOME Software
if [ -f /usr/bin/gnome-software ]; then
  chmod 750 /usr/bin/gnome-software
  chown root:root /usr/bin/gnome-software
fi

# Snap Store
if [ -f /snap/bin/snap-store ]; then
  chmod 750 /snap/bin/snap-store
  chown root:root /snap/bin/snap-store
fi

# Disable terminal shortcut (Ctrl+Alt+T)
sudo -u "$AGENT_NAME" dbus-launch gsettings set \
org.gnome.settings-daemon.plugins.media-keys terminal "['']"

# -------------------------------
# 5. BLOCK PACKAGE MANAGERS
# -------------------------------
echo "Restricting package managers..."

chmod 750 /usr/bin/apt /usr/bin/apt-get 2>/dev/null
chmod 750 /usr/bin/snap 2>/dev/null

# -------------------------------
# 6. BASIC HOME SECURITY
# -------------------------------
echo "Securing home directory..."

chmod 700 /home/$AGENT_NAME
chown "$AGENT_NAME":"$AGENT_NAME" /home/$AGENT_NAME

# -------------------------------
# DONE
# -------------------------------
echo "----------------------------------------"
echo "SETUP COMPLETE"
echo "----------------------------------------"
echo "User: $AGENT_NAME"
echo ""
echo "✔ No sudo access"
echo "✔ Cannot install apps"
echo "✔ Terminal blocked"
echo "✔ App Center blocked"
echo "✔ VPN/WiFi allowed"
echo "✔ GUI working normally"
echo ""
echo "Production-safe, no system breakage."
echo "----------------------------------------"
