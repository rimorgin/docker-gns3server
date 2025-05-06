#!/bin/sh
set -e

# Set default config path if not set
CONFIG=${CONFIG:-/data/config.ini}

# Copy default config if it doesn't exist
if [ ! -f "$CONFIG" ]; then
  echo "[INFO] Copying default config.ini to /data"
  cp /config.ini /data/
fi

# Setup bridge
echo "[INFO] Setting up virtual bridge virbr0"
brctl addbr virbr0 || echo "[WARN] virbr0 already exists"
ip link set dev virbr0 up

# Set bridge address
BRIDGE_ADDRESS=${BRIDGE_ADDRESS:-172.21.1.1}
ip addr add "$BRIDGE_ADDRESS"/24 dev virbr0 2>/dev/null || echo "[WARN] Address $BRIDGE_ADDRESS/24 may already be assigned"

# Extract network prefix and calculate DHCP range
NETWORK_PREFIX=$(echo "$BRIDGE_ADDRESS" | cut -d'/' -f1 | awk -F. '{print $1"."$2"."$3}')
DHCP_START="${NETWORK_PREFIX}.10"
DHCP_END="${NETWORK_PREFIX}.250"

# Setup NAT
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Start dnsmasq for DHCP
echo "[INFO] Starting dnsmasq DHCP on virbr0 with range $DHCP_START to $DHCP_END"
dnsmasq -i virbr0 -z -h --dhcp-range="$DHCP_START","$DHCP_END",4h &
# Start Docker daemon
echo "[INFO] Starting Docker daemon"
dockerd --storage-driver=vfs --data-root=/data/docker/ &

# Handle SSL option
if [ "$(echo "$SSL" | tr '[:upper:]' '[:lower:]')" = "true" ]; then 
  echo "[INFO] SSL enabled - generating certificates"
  curl -fsSL https://raw.githubusercontent.com/GNS3/gns3-server/master/scripts/create_cert.sh | sh

  echo "[INFO] Starting GNS3 server with SSL"
  gns3server -A \
    --certfile ~/.config/GNS3/ssl/server.cert \
    --certkey ~/.config/GNS3/ssl/server.key \
    --ssl \
    --config "$CONFIG"
else
  echo "[INFO] Starting GNS3 server without SSL"
  gns3server -A --config "$CONFIG"
fi
