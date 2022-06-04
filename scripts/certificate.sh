#!/bin/bash

# Set up certificate for noVNC https access

# Generate OpenSSL certificate for noVNC if does not exist
if [ ! -f /etc/ssl/certs/novnc_cert.pem -o ! -f /etc/ssl/private/novnc_key.pem ]
then
    echo "No certificate found, generating new one..."
    openssl req -new -x509 -days 365 -nodes \
        -subj "/C=US/ST=TX/L=Austin/O=OpenSource/CN=localhost" \
        -out /etc/ssl/certs/novnc_cert.pem \
        -keyout /etc/ssl/private/novnc_key.pem \
        > /dev/null 2>&1
fi

# Combine certificate
cat /etc/ssl/certs/novnc_cert.pem /etc/ssl/private/novnc_key.pem > /etc/ssl/private/novnc_combined.pem
chmod 600 /etc/ssl/private/novnc_combined.pem

echo "Certificate configured."
