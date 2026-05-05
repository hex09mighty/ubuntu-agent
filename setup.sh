#!/bin/bash

# --- 1. SETTINGS ---
AGENT_NAME="agent01"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

echo "------------------------------------------------"
echo "Initializing Hardened Agent Architecture..."
echo "------------------------------------------------"

# --- 2. CREATE AGENT USER ---
if id "$AGENT_NAME" &>/dev/null; then
    echo "User $AGENT_NAME already exists."
else
    # Use normal shell (IMPORTANT)
    useradd -m -s /bin/bash "$AGENT_NAME"
    echo "Set password for $AGENT_NAME:"
    passwd "$AGENT_NAME"
fi

# --- 3. REMOVE ADMIN ACCESS ---
deluser "$AGENT_NAME" sudo 2>/dev/null

# --- 4. DISABLE HOTKEYS (Terminal & Shortcuts) ---
echo "Disabling Terminal hotkeys..."
sudo -u "$AGENT_NAME" dbus-launch gsettings set \
org.gnome.settings-daemon.plugins.media-keys terminal "['']"

sudo -u "$AGENT_NAME" dbus-launch gsettings set \
org.gnome.desktop.wm.keybindings panel-main-menu "['']"

# --- 5. ALLOW VPN / WIFI (POLKIT) ---
echo "Allowing VPN & network control..."

cat <<EOF > /etc/polkit-1/rules.d/50-agent-network.rules
polkit.addRule(function(action, subject) {
    if (
        subject.user == "$AGENT_NAME" &&
        action.id.indexOf("org.freedesktop.NetworkManager") == 0
    ) {
        return polkit.Result.YES;
    }
});
EOF

chmod 644 /etc/polkit-1/rules.d/50-agent-network.rules

# --- 6. BASIC HOME HARDENING ---
chown root:root /home/$AGENT_NAME/.bashrc /home/$AGENT_NAME/.profile
chmod 644 /home/$AGENT_NAME/.bashrc

# --- 7. SECURE ADMIN HOME ---
ADMIN_USER=$(logname)
chmod 700 /home/$ADMIN_USER

echo "------------------------------------------------"
echo "SETUP COMPLETE"
echo "------------------------------------------------"
echo "✔ Terminal shortcut disabled"
echo "✔ No sudo access"
echo "✔ VPN/WiFi allowed"
echo "✔ App icons NOT hidden"
echo "✔ Stable system (no breakage)"
echo "------------------------------------------------"
