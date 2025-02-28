#!/bin/bash
set -e

declare -A icons=(
    ["firefox"]="FF"
    ["chrome"]="GC"
    ["code"]="vs-code"
    ["code-url-handler"]="vs-code"
    ["kitty"]="term"
)

function reset {
    local cmds=""
    for id in $(hyprctl workspaces -j | jq -r '.[].id' | tr '\n' ' '); do
        cmds+="dispatch renameworkspace $id $id ; "
    done

    hyprctl --batch "$cmds"
}

trap reset EXIT

function set_workspacenames {
    declare -A workspaces

    for id in $(hyprctl workspaces -j | jq -r '.[].id' | tr '\n' ' '); do
        workspaces[$i]=""
    done

    local i=0
    local id=0
    for j in $(hyprctl clients -j | jq -r '.[] | .workspace.id, .class' | tr '\n' ' '); do
        if [ $i = 0 ];
            id=$j
            i=1
        else
            workspaces[$id]+="$j "
            i=0
        fi
    done

    local cmds=""

    for id in ${!workspaces[@]}; do
        local apps=${workspaces[${id}]}

        local name="$id"
        if [ "$apps" != "" ]; then
            name+=": $apps"
        fi

        cmds+="dispatch renameworkspace $id $name ; "
    done


    hyprctl --batch "$cmds"
}

function handle {
    # openwindow>>562169eb53e0,1,foot,foot
    # closewindow>>562169eb53e0
    # movewindow>>562169eb53e0,2
    if [[ ${1:0:10} == "openwindow" ]]; then
        set_workspacenames
    fi

    if [[ ${1:0:11} == "closewindow" ]]; then
        set_workspacenames
    fi

    if [[ ${1:0:10} == "movewindow" ]]; then
        set_workspacenames
    fi
  fi
}

socat - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do handle "$line"; done
