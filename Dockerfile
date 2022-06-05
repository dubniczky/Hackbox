# Hackbox - Kali Linux Container With GUI
# Author: Richard Antal Nagy

# Source image arguments
ARG KALI_DIST="kali-rolling"
ARG KALI_TAG="latest"

# Source image
FROM kalilinux/${KALI_DIST}:${KALI_TAG}

# Build arguments
ARG METAPACKAGE="kali-tools-top10"
ARG VNC_PASSWORD="toor"

# Disable interactivity
ENV DEBIAN_FRONTEND noninteractive \
    DEBIAN_PRIORITY=critical \
    NEEDRESTART_MODE a

# Update packages
RUN apt -q update && \
    apt -qy upgrade

# Install kali packages
RUN apt -qy install kali-linux-core

# Install kali xfce desktop (takes a long time ~5m)
RUN apt -qy install kali-desktop-xfce

# Install vnc and components
RUN apt -qy install \
    tightvncserver \
    dbus \
    dbus-x11 \
    novnc \
    net-tools

# Install extra packages
RUN apt -qy install \
    ${METAPACKAGE} \
    nano \
    mc \
    unzip \
    filezilla \
    sqlite3 \
    iputils-ping \
    traceroute \
    skipfish \
    htop \
    autopsy \
    dirb \
    hashcat \
    wordlists

# Create kali user
ENV USER=kali
RUN useradd -r -s /bin/zsh -m ${USER}; \
    echo -e "${USER}\tALL=(ALL:ALL)\tNOPASSWD:ALL" >> /etc/sudoers

# Generate noVNC HTTPS certificate
WORKDIR /etc/ssl
RUN openssl req -new -x509 -days 365 -nodes \
        -subj "/C=US/ST=TX/L=Austin/O=OpenSource/CN=localhost" \
        -out certs/novnc_cert.pem \
        -keyout private/novnc_key.pem \
        > /dev/null 2>&1
RUN cat certs/novnc_cert.pem private/novnc_key.pem > private/novnc_combined.pem
RUN chmod 600 private/novnc_combined.pem

# Set up VNC password
RUN mkdir -p /root/.vnc/; \
    echo ${VNC_PASSWORD} | vncpasswd -f > /root/.vnc/passwd; \
    chmod 600 /root/.vnc/passwd

# Copy scripts
COPY /scripts /root/scripts
WORKDIR /root/scripts/
RUN chmod +x ./*

# Run optional installer scripts
RUN ./vscodium.sh || echo "VSCodium was not installed"
RUN ./nodejs.sh || echo "NodeJS was not installed"
RUN ./python.sh || echo "Python components were not installed"
RUN ./signal.sh || echo "Signal was not installed"

# Cleanup scripts
WORKDIR /
RUN rm -rf /root/scripts

# Delete unnecessary packages
RUN apt -qy purge \
    xfce4-power-manager-data

# Clean package cache and unused packages
RUN apt -qy clean && \
    apt -qy autoremove

# Cleanup user files
WORKDIR /home/${USER}
RUN rm -rf Documents Downloads Music Pictures Public Templates Videos

# Entrypoint
WORKDIR $HOME
COPY start.sh .start.sh
RUN chmod 700 .start.sh
ENTRYPOINT [ "./.start.sh" ]
