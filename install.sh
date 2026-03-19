#!/bin/bash
echo "🚀 Installing Cloud Panel dependencies..."
apt update -y
apt install -y python3 python3-pip git docker.io nginx

echo "✅ Installing Python packages..."
pip3 install -r requirements.txt

echo "✅ Starting Cloud Panel..."
nohup python3 app.py &
echo "Visit: http://YOUR_SERVER_IP:5000"
