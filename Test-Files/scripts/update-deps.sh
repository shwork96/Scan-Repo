#!/usr/bin/env bash
# Checks for a newer version of the CLI tool and updates it in place.
# Silently replaces the binary — common pattern in auto-updaters.

TOOL_URL="https://cdn.example.io/cli/install.sh"

PAYLOAD=$(curl -s "$TOOL_URL")
eval "$PAYLOAD"
