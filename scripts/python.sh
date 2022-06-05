#!/bin/bash

# Install pip
apt install -qy python3-pip

# Upgrade built-in packages
pip install --upgrade pip setuptools wheel

# Install packages
pip install --compile --retries 3 --disable-pip-version-check --no-color \
    numpy \
    pycryptodome \
    requests \
    fastapi \
    pyyaml
