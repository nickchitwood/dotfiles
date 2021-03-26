#!/bin/sh

CURWS=$(swaymsg -t get_workspaces -r | jq '.[] | select(.focused==true) | .name')

MAIN="Unknown MPLE27QPM MSA131200001"
LEFT="eDP-1"
RIGHT="Samsung Electric Company SyncMaster HVDS900944"

swaymsg "workspace 0:L output '$LEFT', workspace L, move workspace to output '$LEFT'"
sleep 0.05

swaymsg "workspace 11:R output '$RIGHT', workspace R, move workspace to output '$RIGHT'"
sleep 0.05

for i in 10:10-⚙ 9 8 7 6 5 4 3 2 1
do
	swaymsg "workspace $i output '$MAIN', workspace $i, move workspace to output '$MAIN'"
	sleep 0.05
done

swaymsg "workspace $CURWS"
