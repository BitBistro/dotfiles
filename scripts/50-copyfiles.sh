#!/bin/bash
if [ ! /usr/bin/rsync ]; then
    echo "rsync not installed"
    exit 255;
fi

rsync -avCP "$1/src/" "$HOME"
