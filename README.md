# Ubuntu Agent Lockdown Utility

A security hardening script designed for call center environments. This utility converts a standard Ubuntu installation into a restricted "Thin Client" for agents, ensuring they can only access specified tools (Browser/RDP) while maintaining a high security posture.

## 🛡️ Security Features
- **Restricted Shell (rbash):** Prevents agents from changing directories (`cd`) or modifying system environments.
- **GUI Lockdown:** Hides the Ubuntu App Center and Terminal from the application grid.
- **Hotkey Disabling:** Disables `Ctrl+Alt+T` and other terminal shortcuts for the agent.
- **Process Isolation:** Implements `hidepid=2` so agents cannot see system processes or security services (SentinelOne/Bitdefender).
- **Admin Privacy:** Locks the root/admin home directory to prevent unauthorized data access.
- **Zero Sudo:** The agent account is created without administrative privileges.

## 🚀 Installation

Run the setup script directly from this repository using `wget`. Ensure you run this as a user with `sudo` privileges.

```bash
wget -qO setup.sh https://raw.githubusercontent.com/hex09mighty/ubuntu-agent/refs/heads/main/setup.sh && sudo bash setup.sh
```

## 🛠️ Configuration Details
The script performs the following actions:
1. **User Creation:** Creates a dedicated user (default: `agent01`) with a restricted bash shell.
2. **Desktop Hardening:** Uses GSettings to wipe terminal keybindings.
3. **Menu Sanitization:** Creates `.desktop` overrides with `NoDisplay=true` for sensitive system apps.
4. **FSTAB Hardening:** Updates `/etc/fstab` to ensure process hiding persists across reboots.

## 📋 Post-Installation Checklist
To complete the setup, log in as the **agent** once to:
1. Set your **Browser** and **RDP Client** (Remmina) to "Startup Applications".
2. Ensure Bitdefender/SentinelOne policies are pushed from your central console (this script does not interfere with their operation).

## ⚠️ Requirements
- Ubuntu 22.04 LTS or 24.04 LTS.
- Active Internet connection for initial setup.

---
**Note:** This script is designed for environments where security software like SentinelOne or Bitdefender is already handling USB and peripheral blocking.
