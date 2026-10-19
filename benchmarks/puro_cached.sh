#!/bin/bash
set -e

curl -o- https://puro2.phntm.xyz/install.sh | bash
export PATH="$PATH:$HOME/.puro/bin"

puro2 --no-progress -v create example 3.3.5
puro2 --no-progress -v rm example

echo "=============================================================="

start_time=$(date +%s.%3N)
start_network=$(cat /proc/net/dev | perl -nle 'm/eth0: *([^ ]*)/; print $1' | tr -d '[:space:]')

puro2 --no-progress -v create example2 3.3.5

create_time=$(date +%s.%3N)

puro2 --no-progress -v -e example2 flutter --version

end_time=$(date +%s.%3N)

create_duration=$(echo "scale=3; $create_time - $start_time" | bc)
run_duration=$(echo "scale=3; $end_time - $create_time" | bc)
total_duration=$(echo "scale=3; $end_time - $start_time" | bc)
echo "Create: ${create_duration}s"
echo "Run: ${run_duration}s"
echo "Total: ${total_duration}s"

end_network=$(cat /proc/net/dev | perl -nle 'm/eth0: *([^ ]*)/; print $1' | tr -d '[:space:]')
total_network=$(echo "scale=3; $end_network - $start_network" | bc)
echo "Network: ${end_network} - ${start_network} = ${total_network} bytes"