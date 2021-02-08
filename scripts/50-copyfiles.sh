#!/bin/bash
if [ ! -e /usr/bin/rsync ]; then
    echo "rsync not installed"
    exit 255;
fi

rsync -avCP "$1/overlay/" "$HOME"
