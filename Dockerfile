FROM kalilinux/kali-rolling:latest

ENV USER root

# Disable interactivity
ENV DEBIAN_FRONTEND noninteractive \
    NEEDRESTART_MODE a \
    DEBIAN_PRIORITY=critical

# Update packages
RUN apt -q update && \
    apt -qy upgrade

# Install kali packages
RUN apt -qy install kali-linux-core

# Install kali xfce desktop (takes a long time ~5m)
RUN apt -qy install kali-desktop-xfce

# Install vnc and components
RUN apt -qy install tightvncserver dbus dbus-x11 novnc net-tools

# Set up VNC password
RUN mkdir -p /root/.vnc/; \
    echo toor | vncpasswd -f > /root/.vnc/passwd; \
    chmod 600 /root/.vnc/passwd

# Extra packages
RUN apt -qy install \
    kali-tools-top10 \
    nano \
    mc \
    filezilla

# Copy scripts
COPY /scripts /root/scripts
WORKDIR /root/scripts/
RUN chmod +x ./*

# Run scripts
RUN ./certificate.sh
RUN ./vscodium.sh || true
RUN ./nodejs.sh || true
RUN ./python.sh || true
RUN ./signal.sh || true
RUN ./vscodium.sh || true

# Cleanup scripts
WORKDIR /
RUN rm -rf /root/scripts

# Cleanup user files
WORKDIR $HOME
RUN rm -rf Documents Downloads Music Pictures Public Templates Videos

# Clean package cache and unused packages
RUN apt -qy clean && \
    apt -qy autoremove

# Entrypoint
WORKDIR /root
COPY start.sh .start.sh
RUN chmod 700 .start.sh
ENTRYPOINT [ "./.start.sh" ]
