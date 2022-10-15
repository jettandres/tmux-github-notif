#!/usr/bin/env bash

get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value="$(tmux show-option -gqv "$option")"

    if [[ -z "$option_value" ]]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

interpolations=(
    "\#{gh_notif}"
)

interpolation_cmd=(
    "gh api -H 'Accept: application/vnd.github+json' /notifications | jq '[.[]] | length'"
)

set_tmux_option() {
    local option=$1
    local value=$2
    tmux set-option -gq "$option" "$value"
}

do_interpolation() {
    local result="$1"
    for ((i=0; i < ${#interpolations[@]}; i++)); do
        local cmd="${interpolation_cmd[$i]}"
        cmd="#(${cmd})"
	    result="${result//${interpolations[$i]}/  ${cmd}}"
    done
    echo "$result"
}

update_tmux_option() {
	local option=$1
	local option_value=$(get_tmux_option "$option")
	local new_option_value=$(do_interpolation "$option_value")
	set_tmux_option "$option" "$new_option_value"
}

main() {
	update_tmux_option "status-right"
	update_tmux_option "status-left"
}
main

