#!/bin/bash
set -e

# Start mock UniFi controller in background
/home/egx570/repos/rylan-canon-library/.venv/bin/python /home/egx570/repos/rylan-canon-library/tests/integration/mock_unifi.py &
MOCK_PID=$!

# Ensure mock server is cleaned up on exit
trap 'kill $MOCK_PID' EXIT

# Wait for mock server to start
sleep 2

# Run ansible-inventory
cd /home/egx570/repos/rylan-canon-library/tests/integration
ansible-inventory -i test.unifi_inventory.yml --list
