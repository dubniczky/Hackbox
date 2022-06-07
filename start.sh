#!/bin/bash

# Generate new certificate each time the container starts
# It is important not to ship the same certificate in the pre-built containers
openssl req \
    -new \
    -x509 \
    -days ${CERT_LIFETIME} \
    -nodes \
    -subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=OpenSource/CN=localhost" \
    -out ${CERT_LOC}/certs/novnc_cert.pem \
    -keyout ${CERT_LOC}/private/novnc_key.pem \
    > /dev/null 2>&1
cat ${CERT_LOC}/certs/novnc_cert.pem ${CERT_LOC}/private/novnc_key.pem > \
    ${CERT_LOC}/private/novnc_combined.pem
chmod 600 ${CERT_LOC}/private/novnc_combined.pem

# Set VNC password
# Must be done upon start, because it may be overwritten by manual env args
echo "${VNC_PASSWORD}" | vncpasswd -f > /root/.vnc/passwd; \
    chmod 600 /root/.vnc/passwd
# Set user password
echo "${VNC_PASSWORD}" | passwd --stdin ${USER}

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
