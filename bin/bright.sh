#!/bin/bash

step=10

case "$1" in
+)
	xbacklight -inc $step
;;
-)
	xbacklight -dec $step
;;
esac
