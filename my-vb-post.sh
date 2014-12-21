#!/bin/sh
amixer -s<<EOF
  sset Master unmute
  sset Master 100%
  sset PCM unmute
  sset PCM 100%
EOF
alsactl store
speaker-test -c2
