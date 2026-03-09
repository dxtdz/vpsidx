#!/usr/bin/env bash

# =======================================
#   AUTHOR    : SDGAMER (Streamlined)
#   TOOL      : DEBIAN 11/12/13 RDP INSTALLER
# =======================================

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- ROOT CHECK ----------
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root! Use 'sudo -i' or 'sudo su'.${NC}"
   exit 1
fi

# ---------- OS DETECTION ----------
detect_debian() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "debian" ]; then
            echo -e "${RED}Error: Your OS is $ID. This script is ONLY for Debian!${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Error: OS detection failed!${NC}"
        exit 1
    fi
}

# ---------- BANNER ----------
banner() {
clear
echo -e "${CYAN}"
cat <<'EOF'
 ██████╗██████╗  ██████╗  █████╗ ███╗   ███╗███████╗██████╗ 
██╔════╝██╔══██╗██╔════╝ ██╔══██╗████╗ ████║██╔════╝██╔══██╗
╚█████╗ ██║  ██║██║  ███╗███████║██╔████╔██║█████╗  ██████╔╝
 ╚════██║██║  ██║██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  ██╔══██╗
██████╔╝██████╔╝╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗██║  ██║
╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
EOF
echo -e "${GREEN}         DEBIAN 11/12/13 RDP INSTALLER${NC}"
echo "======================================="
}

# ---------- HELPERS ----------
success_msg() {
    echo -e "\n${GREEN}✔ $1 Process Completed Successfully!${NC}"
    echo -e "${YELLOW}Press Enter to return to Menu...${NC}"
    read -r < /dev/tty
}

# ---------- FULL RDP SETUP ----------
install_rdp_full() {
    banner
    echo -e "${YELLOW}Starting Debian Full RDP Setup (XRDP + XFCE)...${NC}"
    
    echo -e "${CYAN}Set a password for 'root' user (This will be your RDP Login):${NC}"
    passwd root

    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y debconf-utils

    echo "keyboard-configuration keyboard-configuration/layout select English (US)" | debconf-set-selections
    echo "keyboard-configuration keyboard-configuration/layoutcode string us" | debconf-set-selections
    echo "keyboard-configuration keyboard-configuration/modelcode string pc105" | debconf-set-selections

    echo -e "${YELLOW}Installing XFCE4 and XRDP...${NC}"
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" xfce4 xfce4-goodies xrdp

    sudo systemctl enable xrdp --now
    echo "xfce4-session" > ~/.xsession
    sudo adduser xrdp ssl-cert
    
    sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
    
    cat <<EOF > /etc/polkit-1/localauthority/50-network-manager.d/45-allow-colord.pkla
[Allow Colord]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

    sudo systemctl restart xrdp
    unset DEBIAN_FRONTEND
    
    echo -e "\n${GREEN}✔ DONE! Remote Desktop is ready.${NC}"
    echo -e "${YELLOW}RDP Port: 3389 | User: root${NC}"
    success_msg "Debian RDP Setup"
}

# ---------- BROWSERS MENU (CLEANED) ----------
browsers_menu() {
    banner
    echo -e "${CYAN}--- [2] WEB BROWSERS ---${NC}"
    echo -e "${YELLOW}1.${NC} Google Chrome"
    echo -e "${YELLOW}2.${NC} Firefox ESR"
    echo -e "${YELLOW}3.${NC} Brave Browser"
    echo -e "${YELLOW}0.${NC} Back"
    echo -ne "${CYAN}Select: ${NC}"
    read -r b < /dev/tty
    case $b in
        1) 
           apt update -y && apt install -y wget
           wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
           apt install -y ./google-chrome*.deb
           rm -f google-chrome*.deb; success_msg "Chrome" ;;
        2) 
           apt up
