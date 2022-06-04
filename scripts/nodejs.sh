#!/bin/bash

# Install nodejs and package manager
apt install -y nodejs npm

# Check versions
node -v
npm -v

# Install global packages
npm i -g yarn
npm i -g pnpm
npm i -g nodemon
npm i -g http-server

# List global packages
echo "Installed global Node packages:"
npm ls -g --depth=0
