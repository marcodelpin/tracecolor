#!/bin/bash
# Proxmox Admin User Setup Script
# Creates admin users with limited sudo privileges

set -e

echo "========================================"
echo "Proxmox Admin User Setup"
echo "========================================"
echo

# Configuration
ADMIN_USER="pvadmin"
UPDATE_USER="updater"
SUDO_GROUP="sudo"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

log_info "Creating admin users for Proxmox management..."

# Create pvadmin user
if ! id "$ADMIN_USER" &>/dev/null; then
    log_info "Creating user: $ADMIN_USER"
    useradd -m -s /bin/bash "$ADMIN_USER"
    usermod -aG "$SUDO_GROUP" "$ADMIN_USER"
    log_info "User $ADMIN_USER created and added to sudo group"
else
    log_warn "User $ADMIN_USER already exists"
fi

# Create updater user  
if ! id "$UPDATE_USER" &>/dev/null; then
    log_info "Creating user: $UPDATE_USER"
    useradd -m -s /bin/bash "$UPDATE_USER"
    usermod -aG "$SUDO_GROUP" "$UPDATE_USER"
    log_info "User $UPDATE_USER created and added to sudo group"
else
    log_warn "User $UPDATE_USER already exists"
fi

# Configure sudoers for limited privileges
log_info "Configuring sudo privileges..."

cat > /etc/sudoers.d/proxmox-admins << EOF
# Proxmox admin users - limited privileges
$ADMIN_USER ALL=(ALL) NOPASSWD: /usr/sbin/pct, /usr/sbin/qm, /bin/systemctl
$UPDATE_USER ALL=(ALL) NOPASSWD: /usr/bin/apt update, /usr/bin/apt upgrade, /usr/bin/apt autoremove
EOF

log_info "Sudo privileges configured"

# Set up SSH directories
for user in "$ADMIN_USER" "$UPDATE_USER"; do
    user_home=$(eval echo "~$user")
    ssh_dir="$user_home/.ssh"
    
    log_info "Setting up SSH for user: $user"
    
    if [ ! -d "$ssh_dir" ]; then
        mkdir -p "$ssh_dir"
        chown "$user:$user" "$ssh_dir"
        chmod 700 "$ssh_dir"
        log_info "Created SSH directory for $user"
    fi
    
    # Create authorized_keys if it doesn't exist
    auth_keys="$ssh_dir/authorized_keys"
    if [ ! -f "$auth_keys" ]; then
        touch "$auth_keys"
        chown "$user:$user" "$auth_keys"
        chmod 600 "$auth_keys"
        log_info "Created authorized_keys for $user"
    fi
done

echo
log_info "========================================"
log_info "Setup completed successfully!"
log_info "========================================"
log_info "Users created:"
log_info "  - $ADMIN_USER (VM/Container management)"
log_info "  - $UPDATE_USER (System updates)"
echo
log_warn "Next steps:"
log_warn "1. Add SSH public keys to authorized_keys files"
log_warn "2. Test SSH connections"
log_warn "3. Disable root SSH if desired"
echo