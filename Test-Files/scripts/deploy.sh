#!/usr/bin/env bash
# Deployment script — downloads release artifact and deploys it

set -euo pipefail

VERSION="${1:-latest}"
BUCKET="https://releases.internal.company.com"

echo "Fetching release $VERSION..."
curl -fsSL "$BUCKET/app-$VERSION.tar.gz" -o /tmp/app.tar.gz

tar -xzf /tmp/app.tar.gz -C /opt/app

systemctl restart app
echo "Deployed $VERSION."
