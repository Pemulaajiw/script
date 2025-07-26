#!/bin/bash
# ================================================
# DIRECT PORT FORWARDING CONFIGURATION FOR LXD CONTAINER
# ================================================

# Container name (adjust according to your container)
CONTAINER_NAME="ubuntu20"

# Port forwarding configuration
declare -A PORTS=(
    ["xray443"]="443:443"
    ["xray80"]="80:80"
    ["xray10000"]="10000:10000"
    ["sshws8880"]="8880:8880"
    ["sshws2082"]="2082:2082"
    ["sshws8080"]="8080:8080"
    ["dropbear22"]="149:149"
    ["dropbear109"]="109:109"
    ["dropbear143"]="143:143"
    ["dropbear442"]="442:442"
    ["haproxy8443"]="8443:8443"
    ["haproxy8080"]="8080:8080"
    ["haproxy3000"]="3000:3000"
)

# Check if container exists
if ! lxc list | grep -q "$CONTAINER_NAME"; then
    echo "Error: Container $CONTAINER_NAME not found!"
    exit 1
fi

echo "Setting up port forwarding for container $CONTAINER_NAME..."

# Configure each port forwarding
for name in "${!PORTS[@]}"; do
    IFS=':' read -ra PORT_MAP <<< "${PORTS[$name]}"
    HOST_PORT="${PORT_MAP[0]}"
    CONTAINER_PORT="${PORT_MAP[1]}"
    
    echo "Configuring $name (host:$HOST_PORT -> container:$CONTAINER_PORT)"
    
    # Remove existing device if exists
    lxc config device remove "$CONTAINER_NAME" "$name" 2>/dev/null || true
    
    # Add new port forwarding
    lxc config device add "$CONTAINER_NAME" "$name" proxy \
        listen=tcp:0.0.0.0:"$HOST_PORT" \
        connect=tcp:127.0.0.1:"$CONTAINER_PORT"
done

echo "Port forwarding configuration completed successfully"
echo "List of configured ports:"
lxc config device list "$CONTAINER_NAME" | grep -E "$(IFS='|'; echo "${!PORTS[*]}")"
