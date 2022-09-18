if [ -f ~/.bash_aliases ]; then
    XSUM="$(md5sum ~/.bash_aliases | awk '{print $1}')"
    if [ "$XSUM" == "b86a5a0848f0c1d0e93f68769d5f9140" ]; then
        echo "Cleaning up old alias file, no longer used"
        rm -f ~/.bash_aliases
    fi
fi
