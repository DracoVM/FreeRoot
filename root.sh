#!/bin/bash

# Function to install an OS with proot
install_os() {
  local os_name="$1"
  local repo="$2"

  # Check if proot is installed
  if ! command -v proot &> /dev/null; then
    echo "Error: proot is not installed. Please install it first."
    exit 1
  fi

  # Create a directory for the OS
  mkdir -p "$HOME/.local/share/proot/rootfs/$os_name"

  # Download and extract the OS
  echo "Downloading and extracting $os_name..."
  wget -nv "$repo" -O "$HOME/.local/share/proot/rootfs/$os_name/os.tar.gz"
  tar -xzf "$HOME/.local/share/proot/rootfs/$os_name/os.tar.gz" -C "$HOME/.local/share/proot/rootfs/$os_name"

  # Run proot
  echo "Starting $os_name..."
  proot -r "$HOME/.local/share/proot/rootfs/$os_name" /bin/bash
}

# Prompt for OS name
read -p "Enter the name of the OS you want to install (e.g., ubuntu, debian): " os_name

# Check if the OS name is valid (add more options as needed)
case "$os_name" in
  ubuntu)
    repo="https://releases.ubuntu.com/22.04/ubuntu-22.04.1-desktop-amd64.iso"
    install_os "$os_name" "$repo"
    ;;
  debian)
    repo="https://www.debian.org/CD/http/debian-cd/current/amd64/iso-cd/debian-11.6.0-amd64-netinst.iso"
    install_os "$os_name" "$repo"
    ;;
  *)
    echo "Invalid OS name."
    exit 1
    ;;
esac
