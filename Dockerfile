FROM kalilinux/kali-rolling:latest

# TODO: remove unused
ENV USER root \
    NOVNC_PORT 8080 \
    VNC_PORT 5900 \    
    VNC_PASSWORD toor \
    VNC_DISPLAY 1920x1080 \
    VNC_DEPTH 16

# Disable interactivity
ENV DEBIAN_FRONTEND noninteractive \
    NEEDRESTART_MODE a \
    DEBIAN_PRIORITY=critical

# Update packages
RUN apt -q update && \
    apt -qy upgrade

# Install kali packages
RUN apt -qy install kali-linux-core

# Install kali xfce desktop
RUN apt -qy install kali-desktop-xfce

# Install vnc and components
RUN apt -qy install tightvncserver dbus dbus-x11 novnc net-tools

# Set up VNC password
RUN mkdir -p /root/.vnc/; \
    echo $VNC_PASSWORD | vncpasswd -f > /root/.vnc/passwd; \
    chmod 600 /root/.vnc/passwd

# Extra packages
RUN apt -qy install \
    kali-tools-top10 \
    nano

# Run scripts
COPY /scripts /root/scripts
WORKDIR /root/scripts/
RUN chmod +x ./*
RUN ./certificate.sh
RUN ./vscodium.sh

# Clean package cache and unused packages
RUN apt -qy clean && \
    apt -qy autoremove

# Entrypoint
WORKDIR /root
COPY start.sh .start.sh
RUN chmod 700 .start.sh
ENTRYPOINT [ "./.start.sh" ]
