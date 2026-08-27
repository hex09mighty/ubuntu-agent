# Ubuntu Agent Lockdown Utility

A security hardening script for call center environments that converts a standard Ubuntu installation into a restricted "Thin Client" session.

## 🛡️ Security & Session Features
- **X11 Session Enforcement:** Forces the agent session to load under X11 (Xorg) for unattended screen monitoring, keeping Wayland enabled globally for other users.
- **Dynamic User Creation:** Supports passing a custom username as a script argument (defaults to `agent01`).
- **Restricted Environment:** Strips sudo privileges, locks administrative home directories, and enforces restricted shell rules.
- **GUI & Hotkey Lockdown:** Hides Terminal and App Center launcher icons while disabling keybindings (`Ctrl+Alt+T`).
- **Process Isolation:** Applies `hidepid=2` via `/etc/fstab` to hide system security services (SentinelOne/Bitdefender) from the user.

## 🚀 Installation & Usage

### 1. New Deployments
Run the setup script directly using `wget`. Pass a custom username as an argument if needed (e.g., `agent02`), or leave it blank for `agent01`.

```bash
# Default (agent01)
wget -qO setup.sh [https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/setup.sh](https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/setup.sh) && sudo bash setup.sh

# Custom username
wget -qO setup.sh [https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/setup.sh](https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/setup.sh) && sudo bash setup.sh agent02

```

### 2. Patch Existing Agent Users

To apply the X11 session enforcement to an already created agent user, run the patch script:

```bash
# Patch default user (agent01)
wget -qO fix-agent-x11.sh [https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/fix-agent-x11.sh](https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/fix-agent-x11.sh) && sudo bash fix-agent-x11.sh

# Patch custom user
wget -qO fix-agent-x11.sh [https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/fix-agent-x11.sh](https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/fix-agent-x11.sh) && sudo bash fix-agent-x11.sh agent02

```

## 📋 Post-Installation Checklist

Log in as the target agent account manually to:

1. Verify the active session type by running `echo $XDG_SESSION_TYPE` (should return `x11`).
2. Set your **Browser** and **RDP Client** (Remmina) in **Startup Applications**.

## ⚠️ Requirements

* Ubuntu 22.04 LTS or 24.04 LTS.
