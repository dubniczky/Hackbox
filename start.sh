#!/bin/bash

# Start VNC server
vncserver :0
    -rfbport $VNC_PORT \
    -geometry $VNC_DISPLAY \
    -depth $VNC_DEPTH \
    > /var/log/vncserver.log 2>&1

# Start noVNC server
/usr/share/novnc/utils/launch.sh
    --listen $NOVNC_PORT
    --vnc localhost:$VNC_PORT \
    --cert /etc/ssl/private/novnc_combined.pem \
    --ssl-only \
    > /var/log/novnc.log 2>&1 &

echo "https://localhost:8080/vnc.html"
echo "certificate fingerprint:"
openssl x509 -in /etc/ssl/certs/novnc_cert.pem -noout -fingerprint -sha256

# Start shell
/bin/zsh
