#!/usr/bin/sh

if pgrep yad > /dev/null
then
	pkill yad
else
	yad --calendar --no-buttons & 
	# sleep 0.1
	# xdotool getactivewindow windowmove 2300 40
fi
