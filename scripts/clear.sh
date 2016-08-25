#!/bin/sh

ASSETS_DIR=$TARGET_DIR/public/assets

echo "$ASSETS_DIR"

if [ -d "$ASSETS_DIR" ]; then
  echo "DELETE $ASSETS_DIR"
  rm -rf $ASSETS_DIR
fi