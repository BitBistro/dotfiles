if [ ! -e /usr/bin/rsync ]; then
     echo "rsync not installed"
     exit 255;
fi

if [ "$WITH_FORCE" != "true" ]; then
     echo "The following files will be overwritten:"
     rsync --info=COPY -IhncO -aCP "$1/overlays/base/" "$HOME" 2>/dev/null | egrep -v 'sending incremental file list|^.*/$'
     if [ -d "$1/overlays/$2" ]; then
          rsync --info=COPY -IhncO -aCP "$1/overlays/$2/" "$HOME" 2>/dev/null | egrep -v 'sending incremental file list|^.*/$'
     fi
     yn=n
     read -p "Continue? (y/n) [n]: " -n1 yn; echo
     if [ "$yn" != "y" ]; then
          echo "Skipping"
          exit 0
     fi
fi

rsync -avCP "$1/overlays/base/" "$HOME"
if [ -d "$1/overlays/$2" ]; then
     rsync -avCP "$1/overlays/$2/" "$HOME"
fi
