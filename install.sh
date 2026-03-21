#!/bin/bash

clear
echo "===================================="
echo "     ☁️ CLOUD PANEL INSTALLER"
echo "===================================="
echo "1. Install Cloud Panel"
echo "2. Install Cloud Node"
echo "3. Cloudflared Setup"
echo "4. Exit"
echo "===================================="

read -p "Select option [1-4]: " option

# ================= PANEL =================
if [ "$option" == "1" ]; then

    echo "Enter GitHub Repo Link:"
    read REPO

    echo "Enter Panel Domain or IP (example: vm.heaven.qzz.io):"
    read PANEL_URL

    echo "Install Path (default: /opt/Cloud-Panel):"
    read PATH_DIR

    if [ -z "$PATH_DIR" ]; then
        PATH_DIR="/opt/Cloud-Panel"
    fi

    echo "Installing dependencies..."
    apt update -y
    apt install -y python3 python3-pip git

    echo "Cloning panel..."
    rm -rf $PATH_DIR
    git clone $REPO $PATH_DIR

    cd $PATH_DIR || exit

    echo "Installing Python packages..."
    pip3 install -r requirements.txt

    echo "Starting panel..."
    pkill -f python3
    nohup python3 app.py > panel.log 2>&1 &

    echo "===================================="
    echo "✅ PANEL INSTALLED!"
    echo "🌐 Open: http://$PANEL_URL/login"
fi

# ================= NODE =================
if [ "$option" == "2" ]; then

    echo "Installing Docker Node..."

    apt update -y
    apt install -y docker.io

    systemctl start docker
    systemctl enable docker

    echo "===================================="
    echo "✅ NODE READY (Docker Installed)"
fi

# ================= CLOUDFLARE =================
if [ "$option" == "3" ]; then

    echo "Installing Cloudflared..."

    apt update -y
    apt install -y wget

    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

    dpkg -i cloudflared-linux-amd64.deb

    echo "===================================="
    echo "Login to Cloudflare:"
    cloudflared tunnel login

    echo "Run tunnel:"
    cloudflared tunnel --url http://localhost:5000
fi

# ================= EXIT =================
if [ "$option" == "4" ]; then
    echo "Exiting..."
    exit
fi

echo "===================================="
echo "✅ DONE"
