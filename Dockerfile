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
ENV DEBIAN_FRONTEND="noninteractive" \
    DEBIAN_PRIORITY="critical" \
    NEEDRESTART_MODE="a"

# Create user
ENV USER="kali"
RUN useradd -r -s /bin/zsh -m ${USER}; \
    echo "${USER}\tALL=(ALL:ALL)\tNOPASSWD:ALL" >> /etc/sudoers

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
RUN apt install -qy \
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

## Install and update nodejs packages
RUN apt install -qy nodejs npm; \
    node -v && npm -v \
    npm i -g yarn
# Using yarn to install further global packages instead of npm because it's generally much faster
RUN npx yarn global add \
        pnpm \
        nodemon \
        http-server
# List directly installed global packages
RUN npm ls -g --depth=0

## Install VSCodium
# Add repository gpg
RUN wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        | gpg --dearmor \
        | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
# Add repository to apt
RUN echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list
# Update package list and install
RUN apt update -q && apt install -qy codium
# Setup alias to start codium with code command
RUN echo 'alias code="DONT_PROMPT_WSL_INSTALL=1 codium --no-sandbox --user-data-dir /home/${USER}"' \
        | tee -a \
            /root/.zshrc \
            /root/.bashrc \
            /home/${USER}/.zshrc \
            /home/${USER}/.bashrc \
        >/dev/null

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
    MASTER_SHELL="/bin/zsh" \
    SHARE_DIR="/share"

# Added default port expose
EXPOSE ${VNC_PORT}
EXPOSE ${NOVNC_PORT}

# Create share volume
RUN mkdir ${SHARE_DIR}

# Copy startup script
WORKDIR /root
COPY start.sh .start.sh
RUN chmod 700 .start.sh

# Define default entry point script
ENTRYPOINT [ "bash" ]
CMD [ ".start.sh" ]
