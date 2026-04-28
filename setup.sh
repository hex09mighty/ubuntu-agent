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
    useradd -m -s /bin/rbash "$AGENT_NAME"
    echo "Set password for $AGENT_NAME:"
    passwd "$AGENT_NAME"
fi

# --- 3. DISABLE HOTKEYS (Terminal & Shortcuts) ---
# We use 'sudo -u agent' to apply these directly to the agent's GNOME profile
echo "Disabling Terminal hotkeys and shortcuts..."
sudo -u "$AGENT_NAME" dbus-launch gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['']"
sudo -u "$AGENT_NAME" dbus-launch gsettings set org.gnome.desktop.wm.keybindings panel-main-menu "['']" # Disables Alt+F1

# --- 4. HIDE TERMINAL & APP CENTER GUI ---
# We don't delete them (so Root can use them), we just hide them from the App Menu
echo "Hiding Terminal and Software Center from GUI..."

# Create a local applications folder for the agent if it doesn't exist
mkdir -p /home/$AGENT_NAME/.local/share/applications

# Copy global desktop files to the agent's local folder and add NoDisplay=true
apps_to_hide=("org.gnome.Terminal.desktop" "org.gnome.Software.desktop" "snap-store_ubuntu-software.desktop")

for app in "${apps_to_hide[@]}"; do
    # Find the app in common locations
    if [ -f "/usr/share/applications/$app" ]; then
        cp "/usr/share/applications/$app" "/home/$AGENT_NAME/.local/share/applications/"
        echo "NoDisplay=true" >> "/home/$AGENT_NAME/.local/share/applications/$app"
    fi
done

# Ensure the agent owns their local overrides
chown -R "$AGENT_NAME":"$AGENT_NAME" /home/$AGENT_NAME/.local

# --- 5. HARDEN HOME & PROCESSES ---
chown root:root /home/$AGENT_NAME/.bashrc /home/$AGENT_NAME/.profile
chmod 644 /home/$AGENT_NAME/.bashrc

# Process Isolation (Hides your security tools from Agent's view)
if ! grep -q "hidepid=2" /etc/fstab; then
    echo "proc /proc proc defaults,hidepid=2 0 0" >> /etc/fstab
    mount -o remount,rw,hidepid=2 /proc
fi

# --- 6. SECURE ADMIN DATA ---
ADMIN_USER=$(logname)
chmod 700 /home/$ADMIN_USER

echo "------------------------------------------------"
echo "SETUP COMPLETE"
echo "------------------------------------------------"
echo "1. Terminal Hotkey: DISABLED"
echo "2. Terminal Icon: HIDDEN"
echo "3. Ubuntu App Center: HIDDEN"
echo "4. Agent Shell: RESTRICTED (rbash)"
echo "------------------------------------------------"
