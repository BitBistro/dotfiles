OSENV="$2"
if [ "$OSENV" == "darwin" ]; then
    defaults -currentHost write -globalDomain AppleFontSmoothing -int 1
    defaults -currentHost write -g CGFontRenderingFontSmoothingDisabled -bool YES
fi
