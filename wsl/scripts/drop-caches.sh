#!/usr/bin/env bash

echo "Dropping caches..."
sudo bash -c "echo 1 > /proc/sys/vm/drop_caches" && echo "Done"
