#!/usr/bin/env bash
set -euo pipefail
k3d cluster delete iot-p3 || true
echo "cluster supprime avec succes."
