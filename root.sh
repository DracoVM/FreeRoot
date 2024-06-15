#!/bin/bash

ROOTFS_DIR="/home/runner" # Specify your desired rootfs location
export PATH="$PATH:~/.local/usr/bin"

# --- Function Definitions ---

# Download OS
download_os() {
  local os_name="$1"
  local repo="$2"

  echo "Downloading $os_name..."
  wget --tries=50 --timeout=1 --no-hsts -O "/tmp/rootfs.tar.xz" "$repo"
}

# Install Debian
install_debian() {
  echo "Installing Debian..."
  tar -xJf /tmp/rootfs.tar.xz -C "$ROOTFS_DIR"
  # Install necessary packages (if needed)
  # ...
}

# Install Ubuntu
install_ubuntu() {
  echo "Installing Ubuntu..."
  tar -xf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"
  # Install necessary packages (if needed)
  # ...
}

# Install Alpine
install_alpine() {
  echo "Installing Alpine..."
  tar -xf /tmp/rootfs.tar.gz -C "$ROOTFS_DIR"
  # Install necessary packages (if needed)
  # ...
}

# Install proot
install_proot() {
  echo "Installing proot..."
  mkdir -p "$ROOTFS_DIR/usr/local/bin"
  wget --tries=50 --timeout=1 --no-hsts -O "$ROOTFS_DIR/usr/local/bin/proot" "https://raw.githubusercontent.com/dxomg/vpsfreepterovm/main/proot-$(uname -m)"
  chmod +x "$ROOTFS_DIR/usr/local/bin/proot"
  touch "$ROOTFS_DIR/.installed"
}

# Setup Networking
setup_networking() {
  echo "Setting up networking..."
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${ROOTFS_DIR}/etc/resolv.conf
  rm -rf /tmp/rootfs.tar.xz /tmp/sbin
}

# Start proot
start_proot() {
  echo "Starting the environment..."
  "$ROOTFS_DIR/usr/local/bin/proot" \
    --rootfs="$ROOTFS_DIR" \
    -0 -w "/root" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit
}

# Get architecture
get_arch() {
  case $(uname -m) in
    x86_64) echo amd64 ;;
    aarch64) echo arm64 ;;
    *) echo "Unsupported architecture"
       exit 1
       ;;
  esac
}

# --- Main Script ---

# Check for proot
if ! command -v proot &> /dev/null; then
  echo "Error: proot is not installed. Please install it first."
  exit 1
fi

# Check if proot is already installed
if [ -e "$ROOTFS_DIR/.installed" ]; then
  echo "Proot environment already setup!"
  echo "Starting the environment..."
  start_proot
  exit 0
fi

# Choose OS
echo "Choose OS:"
echo "1) Debian"
echo "2) Ubuntu (RDP Support)"
echo "3) Alpine"
read -p "Enter OS (1-3): " input

case $input in
  1)
    download_os "Debian" "https://github.com/termux/proot-distro/releases/download/v3.10.0/debian-$(uname -m)-pd-v3.10.0.tar.xz"
    install_debian
    ;;
  2)
    download_os "Ubuntu" "http://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.4-base-$(get_arch).tar.gz"
    install_ubuntu
    ;;
  3)
    download_os "Alpine" "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-minirootfs-3.18.3-$(uname -m).tar.gz"
    install_alpine
    ;;
  *)
    echo "Invalid selection. Exiting."
    exit 1
    ;;
esac

# Install proot
install_proot

# Setup networking
setup_networking

# Start proot
start_proot
