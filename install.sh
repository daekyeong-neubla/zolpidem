#!/bin/bash

set -e -u

readonly archive="/tmp/zolpidem.tar.gz"
readonly services=("zolpidem.service" "deallocator.service")

cd "$(dirname "$(realpath "$0")")"

# Install the services
rm -f "${archive}"
tar --no-same-owner --owner=root --group=developers -cf "${archive}" ./lib ./bin
pushd "${PREFIX:-/usr}" >/dev/null
  sudo tar --mode=775 -xf "${archive}"
popd >/dev/null
rm -f "${archive}"
sudo systemctl daemon-reload

# Start the services
sudo systemctl enable "${services[@]}"
sudo systemctl start "${services[@]}"
sudo systemctl status "${services[@]}"
