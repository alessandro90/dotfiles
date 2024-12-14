#!/usr/bin/sh

if pgrep yad > /dev/null
then
	pkill yad
else
	yad --calendar &
fi
