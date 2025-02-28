#!/bin/bash

# Terminate already running gammastep instances
killall -q gammastep

# Launch Gammastep
gammastep & disown

# vim:ft=bash:nowrap
