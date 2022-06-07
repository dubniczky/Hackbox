# Hackbox - Kali Linux Container With GUI
# Author: Richard Antal Nagy

# Source image arguments
ARG KALI_DIST="kali-rolling"
ARG KALI_TAG="latest"

# Source image
FROM kalilinux/${KALI_DIST}:${KALI_TAG}

# Build arguments
ARG METAPACKAGE="kali-tools-top10"

# Disable interactivity
ENV DEBIAN_FRONTEND noninteractive \
    DEBIAN_PRIORITY=critical \
    NEEDRESTART_MODE a

# Update packages
RUN apt update -q && \
    apt upgrade -qy

# Install kali packages
RUN apt install -qy kali-linux-core --no-install-recommends

# Install kali xfce desktop (takes a long time ~5m)
RUN apt install -qy kali-desktop-xfce --no-install-recommends

# Install vnc and components
RUN apt install -qy \
        tightvncserver \
        dbus \
        dbus-x11 \
        novnc \
        net-tools

# Install extra packages
RUN apt install -qy --no-install-recommends \
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
        wordlists \
        tor \
        iproute2 \
        wfuzz \
        nfs-common

# Install and update python packages
RUN apt install -qy python3-pip; \
    pip install --upgrade pip setuptools wheel
RUN pip install --compile --retries 3 --disable-pip-version-check --no-color \
        numpy \
        pycryptodome \
        requests \
        fastapi \
        pyyaml

# Create kali user
ENV USER="kali"
RUN useradd -r -s /bin/zsh -m ${USER}; \
    echo "${USER}\tALL=(ALL:ALL)\tNOPASSWD:ALL" >> /etc/sudoers

# Copy scripts
COPY /scripts /root/scripts
WORKDIR /root/scripts/
RUN chmod +x ./*

# Run optional installer scripts
RUN ./vscodium.sh || echo "VSCodium was not installed"
RUN ./nodejs.sh || echo "NodeJS was not installed"
#RUN ./signal.sh || echo "Signal was not installed"

# Cleanup scripts
WORKDIR /
RUN rm -rf /root/scripts

# Delete unnecessary packages
RUN apt purge -qy \
        xfce4-power-manager-data

# Clean package cache and unused packages
RUN apt clean -qy && \
    apt autoremove -qy

# Cleanup user files
WORKDIR /home/${USER}
RUN rm -rf Documents Downloads Music Pictures Public Templates Videos

# Set env
ENV CERT_LIFETIME="30" \
    CERT_C="US" \
    CERT_L="Austin" \
    CERT_ST="ST" \
    CERT_LOC="/etc/ssl" \
    CERT_DOMAIN="localhost" \
    USER_PASSWORD="toor" \
    NOVNC_PORT="8080" \
    VNC_INDEX="0" \
    VNC_PORT="5900" \
    VNC_DISPLAY="1920x1080" \
    VNC_DEPTH="24" \
    VNC_RUNTIME_LOG="/var/log/vnc.log" \
    NOVNC_RUNTIME_LOG="/var/log/novnc.log" \
    USER="kali" \
    MASTER_SHELL="/bin/zsh"

# Entrypoint
WORKDIR /root
COPY start.sh .start.sh
RUN chmod 700 .start.sh
ENTRYPOINT [ "./.start.sh" ]
