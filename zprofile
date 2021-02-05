if [[ -z $DISPLAY ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
  exec sway
fi
if [[ $HOST == "t480" ]]; then
  exec pulseaudio --daemonize
fi
