if [ "$2" == "darwin" ]; then
    defaults -currentHost write -globalDomain AppleFontSmoothing -int 1
    defaults -currentHost write -g CGFontRenderingFontSmoothingDisabled -bool YES
fi
