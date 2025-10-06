# Systemd User Services

## Services Included

- **protonmail-bridge.service** - Proton Mail Bridge IMAP/SMTP gateway
- **aria2.service** - Aria2 download manager
- **screen_lock.service** - Screen lock service

## Deployment with Stow

All service files are managed via GNU Stow. To deploy:

```bash
# From dotfiles root
cd ~/.dotfiles
stow --target=$HOME --restow .

# Or use the Ansible playbook
ansible-playbook bootstrap.yml --tags symlink
```

After stowing, enable the services:
```bash
systemctl --user daemon-reload
systemctl --user enable --now protonmail-bridge.service
systemctl --user enable --now aria2.service
```

---

## Proton Mail Bridge Service

### Overview
Custom systemd service for Proton Mail Bridge that runs in headless mode with GRPC support.

### Why Custom Service?

The official Proton Bridge package installs a desktop autostart file (`/usr/share/applications/proton-bridge.desktop`) which systemd auto-generates as `app-Proton\x20Mail\x20Bridge@autostart.service`. This creates a **conflict** when running both services simultaneously:

- Multiple bridge instances compete for the same lock file
- The vault gets locked by one instance, preventing the other from loading users
- Results in authentication errors: `"no such user"`, `"too many login attempts"`

### Setup Instructions

1. **Copy the service file:**
   ```bash
   cp ~/.dotfiles/.config/systemd/user/protonmail-bridge.service ~/.config/systemd/user/
   ```

2. **Disable the auto-generated service:**
   ```bash
   systemctl --user mask 'app-Proton\x20Mail\x20Bridge@autostart.service'
   ```

3. **Remove the desktop autostart file:**
   ```bash
   rm ~/.config/autostart/'Proton Mail Bridge.desktop'
   ```

4. **Enable and start the custom service:**
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable protonmail-bridge.service
   systemctl --user start protonmail-bridge.service
   ```

### Advantages of Custom Service

- **Resource limits**: MemoryMax (512M), CPUQuota (25%)
- **Debug logging**: `--log-level debug` enabled by default
- **Proper restart policy**: `Restart=on-failure` with 5s delay
- **PATH environment**: Ensures `pass` is accessible for keychain operations
- **Headless operation**: `--grpc --noninteractive` flags for server-like behavior

### After System Reinstall

1. **Deploy dotfiles:**
   ```bash
   cd ~/.dotfiles
   ansible-playbook bootstrap.yml --tags symlink
   ```

2. **Fix Proton Bridge conflict:**
   ```bash
   systemctl --user mask 'app-Proton\x20Mail\x20Bridge@autostart.service'
   rm ~/.config/autostart/'Proton Mail Bridge.desktop'
   ```

3. **Enable services:**
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now protonmail-bridge.service aria2.service
   ```

### Troubleshooting

**Check service status:**
```bash
systemctl --user status protonmail-bridge
```

**View logs:**
```bash
journalctl --user -u protonmail-bridge -f
```

**Verify no duplicate instances:**
```bash
pgrep -a bridge
```

**Check bridge user loading:**
```bash
tail -100 ~/.local/share/protonmail/bridge-v3/logs/*.log | grep "Loading users"
```

Should show: `"Loading users" count="1"` (or more, depending on configured accounts)
