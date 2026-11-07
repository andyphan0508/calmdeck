#!/bin/bash
# Calmdeck installer and updater:
#   curl -fsSL https://andyphan0508.github.io/calmdeck/install.sh | bash
# Downloads the latest release from GitHub, checks it is signed by Calmdeck's team, and copies it to Applications.
set -euo pipefail
URL="https://github.com/andyphan0508/calmdeck/releases/latest/download/Calmdeck.dmg"
TEAM="9LQ3RLWTBT"   # phải khớp UpdateInstall.allowedTeams trong MacCleaner/Features/Updates/UpdateChecker.swift
DEST="/Applications"; [ -w "$DEST" ] || { DEST="$HOME/Applications"; mkdir -p "$DEST"; }
TMP="$(mktemp -d)"; MNT="$TMP/mnt"; mkdir "$MNT"
trap 'hdiutil detach -quiet "$MNT" 2>/dev/null || true; rm -rf "$TMP"' EXIT

echo "Downloading Calmdeck..."
curl -fL --progress-bar -o "$TMP/Calmdeck.dmg" "$URL"
hdiutil attach -quiet -nobrowse -readonly -noautoopen -mountpoint "$MNT" "$TMP/Calmdeck.dmg"
APP="$MNT/Calmdeck.app"
codesign --verify --strict --deep -R="identifier \"com.calmdecklabs.calmdeck\" and anchor apple generic and (certificate leaf[subject.OU] = \"$TEAM\")" "$APP" || { echo "Signature check failed. Not installing."; exit 1; }

osascript -e 'quit app "Calmdeck"' >/dev/null 2>&1 || true
sleep 1
rm -rf "$DEST/Calmdeck.app"
ditto "$APP" "$DEST/Calmdeck.app"
echo "Installed $(defaults read "$DEST/Calmdeck.app/Contents/Info" CFBundleShortVersionString) to $DEST/Calmdeck.app"
open "$DEST/Calmdeck.app"
