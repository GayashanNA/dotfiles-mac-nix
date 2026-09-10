#!/bin/bash
# 70/30 preset: resize the FOCUSED tiled window to 70% of its monitor's
# width; its neighbours share the rest. Bound to ⌥⇧F in aerospace.toml.
#
# AeroSpace has no named layouts, but `resize width` takes an absolute
# value in points. NSScreen.mainScreen is the screen owning the focused
# window, so this follows you across monitors. Undo: ⌥⇧= (balance).
W=$(osascript -l JavaScript -e 'ObjC.import("AppKit"); Math.round($.NSScreen.mainScreen.frame.size.width*0.7)')
exec /opt/homebrew/bin/aerospace resize width "$W"
