#!/bin/sh

CURWS=$(swaymsg -t get_workspaces -r | jq '.[] | select(.focused==true) | .name')

MAIN="Unknown MPLE27QPM MSA131200001"
LEFT="eDP-1"
RIGHT="Samsung Electric Company SyncMaster HVDS900944"

swaymsg "workspace L output '$LEFT', workspace L, move workspace to output '$LEFT'"

swaymsg "workspace R output '$RIGHT', workspace R, move workspace to output '$RIGHT'"

for i in 10-⚙ 9 8 7 6 5 4 3 2 1
do
	swaymsg "workspace $i output '$MAIN', workspace $i, move workspace to output '$MAIN'"
done

swaymsg "workspace $CURWS"
