#!/bin/bash

# Generate new certificate each time the container starts
# It is important not to ship the same certificate in the pre-built containers
openssl req \
    -new \
    -x509 \
    -days ${CERT_LIFETIME} \
    -nodes \
    -subj "/C=${CERT_C}/ST=${CERT_ST}/L=${CERT_L}/O=OpenSource/CN=${CERT_DOMAIN}" \
    -out ${CERT_LOC}/certs/novnc_cert.pem \
    -keyout ${CERT_LOC}/private/novnc_key.pem \
    > /dev/null 2>&1
cat ${CERT_LOC}/certs/novnc_cert.pem ${CERT_LOC}/private/novnc_key.pem > \
    ${CERT_LOC}/private/novnc_combined.pem
chmod 600 ${CERT_LOC}/private/novnc_combined.pem

# Set VNC password
# Must be done upon start, because it may be overwritten by manual env args
mkdir -p /root/.vnc
echo "${USER_PASSWORD}" | vncpasswd -f > /root/.vnc/passwd; \
    chmod 600 /root/.vnc/passwd
# Set user password
echo -e "${USER_PASSWORD}\n${USER_PASSWORD}" | passwd -q ${USER}

# Start VNC server and reroute stdout to log file
echo "Starting VNC server..."
echo "   > port: $VNC_PORT"
echo "   > resoultion: $VNC_DISPLAY"
echo "   > bit-depth: $VNC_DEPTH"
echo "   > runtime log: $VNC_RUNTIME_LOG"
vncserver :$VNC_INDEX \
    -rfbport $VNC_PORT \
    -geometry $VNC_DISPLAY \
    -depth $VNC_DEPTH \
    -rfbauth /root/.vnc/passwd \
    -desktop xfce \
    -alwaysshared \
    > $VNC_RUNTIME_LOG 2>&1
echo "Done."

# Start noVNC server and reroute stdout to log file
echo "Starting noVNC server..."
echo "   > port: $NOVNC_PORT ~> ($VNC_PORT)"
echo "   > runtime log: $NOVNC_RUNTIME_LOG"
echo "   > domain: $CERT_DOMAIN"
/usr/share/novnc/utils/launch.sh \
    --listen $NOVNC_PORT \
    --vnc ${CERT_DOMAIN}:$VNC_PORT \
    --cert ${CERT_LOC}/private/novnc_combined.pem \
    --ssl-only \
    > $NOVNC_RUNTIME_LOG 2>&1 &
echo "Done."

# Display certificate fingerprint
echo "Certificate fingerprint:"
openssl x509 -in ${CERT_LOC}/certs/novnc_cert.pem -noout -fingerprint -sha256

# Display URL (port might change with docker port readdressing)
echo "Default service url: (note that in case you used port forwarding, it might be different)"
echo "https://${CERT_DOMAIN}:$NOVNC_PORT/index.html"

# Start master shell
echo "Setup complete."
echo "Initializing shell.."
${MASTER_SHELL}
