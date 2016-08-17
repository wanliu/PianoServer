#!/bin/sh

ASSETS_DIR=$TARGET_DIR/public/assets
if [ -d "$ASSETS_DIR" ]; then

  rm -rf $ASSETS_DIR
fi