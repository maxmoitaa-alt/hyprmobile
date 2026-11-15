#!/bin/bash -e
# Stage 2: Install packages

# Update and install packages from list
apt-get update
apt-get install -y --no-install-recommends $(grep -v "^#" 00-packages | grep -v "^$" | tr "\n" " ")

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
