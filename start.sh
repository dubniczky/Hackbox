#!/bin/bash

# Start VNC server
VNC_RUNTIME_LOG=/var/log/vnc.log
echo "Starting VNC server..."
echo "   > port: $VNC_PORT"
echo "   > resoultion: $VNC_DISPLAY"
echo "   > bit-depth: $VNC_DEPTH"
echo "   > runtime log: $VNC_RUNTIME_LOG"
vncserver :0 \
    -rfbport $VNC_PORT \
    -geometry $VNC_DISPLAY \
    -depth $VNC_DEPTH \
    > $VNC_RUNTIME_LOG 2>&1

# Start noVNC server
/usr/share/novnc/utils/launch.sh \
    --listen $NOVNC_PORT \
    --vnc localhost:$VNC_PORT \
    --cert /etc/ssl/private/novnc_combined.pem \
    --ssl-only \
    > /var/log/novnc.log 2>&1 &

echo "https://localhost:8080/vnc.html"
echo "certificate fingerprint:"
openssl x509 -in /etc/ssl/certs/novnc_cert.pem -noout -fingerprint -sha256

# Start shell
/bin/zsh