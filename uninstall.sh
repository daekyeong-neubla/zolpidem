#!/bin/bash

readonly archive="/tmp/zolpidem.tar.gz"
readonly services=("deallocator.service" "zolpidem.service")

cd "$(dirname "$(realpath "$0")")"

# Uninstall the services
sudo systemctl status "${services[@]}"
sudo systemctl mask "${services[@]}"
sudo systemctl stop "${services[@]}"
sudo systemctl disable "${services[@]}"
sudo systemctl unmask "${services[@]}"

# Get the list of files to remove
rm -f "${archive}"
tar -cf "${archive}" ./lib ./bin
IFS=$'\n' list=($(tar -tf "${archive}"))
IFS=$' \t\n'
rm -f "${archive}"

# Remove the files and directories
pushd "${PREFIX:-/usr}" >/dev/null
  for item in "${list[@]}"; do
    [ -d "${item}" ] && continue
    sudo rm -f "${item}"
    sudo rmdir "$(dirname "${item}")" 2>/dev/null || true
  done
popd >/dev/null
sudo systemctl daemon-reload
