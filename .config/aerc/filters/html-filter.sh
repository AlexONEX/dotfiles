#!/bin/bash
# Enhanced HTML filter with image support
w3m -I UTF-8 -T text/html -cols $(tput cols) -dump -o display_image=true -o display_borders=1
