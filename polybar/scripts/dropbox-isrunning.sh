case "$1" in
    --toggle)
        if [ "$(pgrep dropbox)" ]; then
            pkill -f dropbox
        else
            dropbox & 
        fi
        ;;
    *)
        if [ "$(pgrep dropbox)" ]; then
            echo -e '\uf16b'
        else
            echo -e '\ufb97'
        fi
        ;;
esac
