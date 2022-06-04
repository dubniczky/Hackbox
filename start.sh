#!/bin/bash

# Start VNC server
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
echo "Done."

# Start noVNC server
echo "Starting noVNC server..."
echo "   > port: $NOVNC_PORT"
echo "   > runtime log: $NOVNC_RUNTIME_LOG"
/usr/share/novnc/utils/launch.sh \
    --listen $NOVNC_PORT \
    --vnc localhost:$VNC_PORT \
    --cert /etc/ssl/private/novnc_combined.pem \
    --ssl-only \
    > $NOVNC_RUNTIME_LOG 2>&1 &
echo "Done."

# Display certificate fingerprint
echo "Certificate fingerprint:"
openssl x509 -in /etc/ssl/certs/novnc_cert.pem -noout -fingerprint -sha256

# Display URL (port might change with docker port readdressing)
echo "https://localhost:$NOVNC_PORT/vnc.html"

# Start shell
/bin/zsh
