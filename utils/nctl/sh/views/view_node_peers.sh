#!/usr/bin/env bash

source "$NCTL"/sh/utils/main.sh

#######################################
# Renders peer set at specified node(s).
# Arguments:
#   Node ordinal identifier.
#######################################
function main()
{
    local NODE_ID=${1}

    if [ "$NODE_ID" = "all" ]; then
        for NODE_ID in $(seq 1 "$(get_count_of_nodes)")
        do
            echo "------------------------------------------------------------------------------------------------------------------------------------"
            do_render "$NODE_ID"
        done
        echo "------------------------------------------------------------------------------------------------------------------------------------"
    else
        do_render "$NODE_ID"
    fi
}

#######################################
# Displays to stdout current node peers.
# Arguments:
#   Node ordinal identifier.
#######################################
function do_render()
{
    local NODE_ID=${1}
    local NODE_ADDRESS_CURL
    local NODE_API_RESPONSE
    
    NODE_ADDRESS_CURL=$(get_node_address_rpc_for_curl "$NODE_ID")
    NODE_API_RESPONSE=$(
        curl -s --header 'Content-Type: application/json' \
            --request POST "$NODE_ADDRESS_CURL" \
            --data-raw '{
                "id": 1,
                "jsonrpc": "2.0",
                "method": "info_get_peers"
            }' | jq '.result.peers'
    )

    if [ -z "$NODE_API_RESPONSE" ]; then
        log "node #$NODE_ID :: peers: N/A"
    else
        log "node #$NODE_ID :: peers:"
        echo "$NODE_API_RESPONSE" | jq
    fi
}

# ----------------------------------------------------------------
# ENTRY POINT
# ----------------------------------------------------------------

unset NODE_ID

for ARGUMENT in "$@"
do
    KEY=$(echo "$ARGUMENT" | cut -f1 -d=)
    VALUE=$(echo "$ARGUMENT" | cut -f2 -d=)
    case "$KEY" in
        node) NODE_ID=${VALUE} ;;
        *)
    esac
done

main "${NODE_ID:-"all"}"
