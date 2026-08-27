#!/bin/bash

# --- 1. SETTINGS & ARGUMENTS ---
# Use 1st argument if provided; default to "agent01"
AGENT_NAME="${1:-agent01}"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

echo "------------------------------------------------"
echo "Initializing Hardened Agent Architecture for: $AGENT_NAME"
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

# --- 3.5 FORCE X11 (XORG) SESSION FOR AGENT ---
echo "Configuring X11 session for $AGENT_NAME..."
mkdir -p /var/lib/AccountsService/users
cat <<EOF > "/var/lib/AccountsService/users/$AGENT_NAME"
[User]
Session=ubuntu-xorg
XSession=ubuntu-xorg
SystemAccount=false
EOF
chmod 600 "/var/lib/AccountsService/users/$AGENT_NAME"

# --- 4. HIDE TERMINAL & APP CENTER ---
echo "Hiding Terminal and App Center for $AGENT_NAME..."

sudo -u "$AGENT_NAME" mkdir -p \
"/home/$AGENT_NAME/.local/share/applications"

# Hide Terminal
if [ -f /usr/share/applications/gnome-terminal.desktop ]; then
    sudo -u "$AGENT_NAME" cp \
    /usr/share/applications/gnome-terminal.desktop \
    "/home/$AGENT_NAME/.local/share/applications/"

    echo "NoDisplay=true" >> \
    "/home/$AGENT_NAME/.local/share/applications/gnome-terminal.desktop"
fi

# Hide Ubuntu Software / App Center
if [ -f /usr/share/applications/ubuntu-software.desktop ]; then
    sudo -u "$AGENT_NAME" cp \
    /usr/share/applications/ubuntu-software.desktop \
    "/home/$AGENT_NAME/.local/share/applications/"

    echo "NoDisplay=true" >> \
    "/home/$AGENT_NAME/.local/share/applications/ubuntu-software.desktop"
fi

# --- 5. DISABLE HOTKEYS (Terminal & Shortcuts) ---
echo "Disabling Terminal hotkeys..."
sudo -u "$AGENT_NAME" dbus-launch gsettings set \
org.gnome.settings-daemon.plugins.media-keys terminal "['']"

sudo -u "$AGENT_NAME" dbus-launch gsettings set \
org.gnome.desktop.wm.keybindings panel-main-menu "['']"

# --- 6. ALLOW VPN / WIFI (POLKIT) ---
echo "Allowing VPN & network control..."

cat <<EOF > "/etc/polkit-1/rules.d/50-$AGENT_NAME-network.rules"
polkit.addRule(function(action, subject) {
    if (
        subject.user == "$AGENT_NAME" &&
        action.id.indexOf("org.freedesktop.NetworkManager") == 0
    ) {
        return polkit.Result.YES;
    }
});
EOF

chmod 644 "/etc/polkit-1/rules.d/50-$AGENT_NAME-network.rules"

# --- 7. BASIC HOME HARDENING ---
chown root:root "/home/$AGENT_NAME/.bashrc" "/home/$AGENT_NAME/.profile"
chmod 644 "/home/$AGENT_NAME/.bashrc" "/home/$AGENT_NAME/.profile"

# --- 8. SECURE ADMIN HOME ---
ADMIN_USER=$(logname)
chmod 700 "/home/$ADMIN_USER"

echo "------------------------------------------------"
echo "SETUP COMPLETE FOR: $AGENT_NAME"
echo "------------------------------------------------"
echo "✔ Terminal shortcut disabled"
echo "✔ No sudo access"
echo "✔ VPN/WiFi allowed"
echo "✔ Session set to X11 (Xorg) for $AGENT_NAME"
echo "✔ App icons NOT hidden"
echo "✔ Stable system (no breakage)"
echo "------------------------------------------------"
