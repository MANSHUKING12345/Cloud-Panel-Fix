#!/bin/bash

echo "🚀 Installing..."

apt update -y
apt install -y python3 python3-pip

pip3 install flask requests

echo "✅ Starting panel..."
nohup python3 app.py &
