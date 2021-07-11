#!/usr/bin/env bash

echo "Compacting memory..."
sudo bash -c "echo 1 > /proc/sys/vm/compact_memory" && echo "Done"
