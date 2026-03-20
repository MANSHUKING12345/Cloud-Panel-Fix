#!/bin/bash

clear
echo "===================================="
echo "     ☁️ CLOUD PANEL INSTALLER"
echo "===================================="
echo "1. Install Cloud Panel"
echo "2. Install Cloud Node"
echo "3. Cloudflared Setup"
echo "===================================="

read -p "Select option [1-3]: " option

# ================= PANEL =================
if [ "$option" == "1" ]; then

    read -p "Enter GitHub Repo Link: " REPO

    if [ -z "$REPO" ]; then
        echo "❌ Repo link required!"
        exit 1
    fi

    read -p "Install Path (default: /opt/Cloud-Panel): " PATH_DIR

    if [ -z "$PATH_DIR" ]; then
        PATH_DIR="/opt/Cloud-Panel"
    fi

    echo "📦 Installing dependencies..."
    apt update -y && apt install -y python3 python3-pip git || {
        echo "❌ Failed to install dependencies"
        exit 1
    }

    echo "📥 Cloning panel..."
    rm -rf $PATH_DIR
    git clone $REPO $PATH_DIR || {
        echo "❌ Git clone failed! Check repo link."
        exit 1
    }

    cd $PATH_DIR || {
        echo "❌ Failed to enter directory"
        exit 1
    }

    # requirements.txt check
    if [ -f "requirements.txt" ]; then
        echo "📦 Installing Python packages..."
        pip3 install -r requirements.txt || echo "⚠️ Some packages failed, continuing..."
    else
        echo "⚠️ requirements.txt not found, skipping..."
    fi

    # app.py check
    if [ ! -f "app.py" ]; then
        echo "❌ app.py not found! Panel cannot start."
        exit 1
    fi

    echo "🚀 Starting panel..."
    pkill -f python3 2>/dev/null
    nohup python3 app.py > panel.log 2>&1 &

    sleep 2

    # check running
    if pgrep -f "python3 app.py" > /dev/null; then
        echo "===================================="
        echo "✅ PANEL INSTALLED & RUNNING!"
        echo "🌐 Open: http://YOUR_IP:5000/login"
    else
        echo "❌ Panel failed to start. Check logs:"
        echo "cat $PATH_DIR/panel.log"
    fi

fi

# ================= NODE =================
if [ "$option" == "2" ]; then

    echo "📦 Installing Docker..."

    apt update -y && apt install -y docker.io || {
        echo "❌ Docker install failed"
        exit 1
    }

    systemctl start docker
    systemctl enable docker

    echo "===================================="
    echo "✅ NODE READY (Docker Installed)"

fi

# ================= CLOUDFLARE =================
if [ "$option" == "3" ]; then

    echo "📦 Installing Cloudflared..."

    apt update -y && apt install -y wget || {
        echo "❌ wget install failed"
        exit 1
    }

    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb || {
        echo "❌ Download failed"
        exit 1
    }

    dpkg -i cloudflared-linux-amd64.deb || {
        echo "❌ Install failed"
        exit 1
    }

    echo "===================================="
    echo "🔐 Login to Cloudflare:"
    cloudflared tunnel login

    echo "🌐 Starting tunnel..."
    cloudflared tunnel --url http://localhost:5000

fi

# ================= INVALID =================
if [[ "$option" != "1" && "$option" != "2" && "$option" != "3" ]]; then
    echo "❌ Invalid option!"
fi

echo "===================================="
echo "✅ DONE"
