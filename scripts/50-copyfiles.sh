if [ ! -e /usr/bin/rsync ]; then
    echo "rsync not installed"
    exit 255;
fi

rsync -avCP "$1/overlays/base/" "$HOME"
if [ -d "$1/overlays/$2" ]; then
    rsync -avCP "$1/overlays/$2/" "$HOME"
fi
