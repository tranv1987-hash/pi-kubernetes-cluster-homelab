#!/bin/bash
NODE_NAME=$1
if [ -z "$NODE_NAME" ]; then
    echo "Usage: $0 <node-hostname>"
    exit 1
fi
kubectl cordon $NODE_NAME
kubectl drain $NODE_NAME --ignore-daemonsets --delete-emptydir-data
read -p "Press Enter after the node has rebooted..."
kubectl uncordon $NODE_NAME