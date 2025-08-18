#!/bin/bash
set -uo pipefail
CONFIG_DIR="$HOME/.config/the-house"
BALANCE_FILE="$CONFIG_DIR/balance.txt"
BLACKLIST_FILE="$CONFIG_DIR/blacklist.txt"
LOG_FILE="$CONFIG_DIR/log.txt"
PACT_FILE="$CONFIG_DIR/pact.txt"

mkdir -p "$CONFIG_DIR"
touch "$BALANCE_FILE" "$LOG_FILE"
player_money=$(<"$BALANCE_FILE")

check_pact_loss() {
    if [[ -f "$PACT_FILE" ]]; then
        echo "well dear player, remember the pact?"
        player_money=1
        echo "$player_money" > "$BALANCE_FILE"
        echo "$(date): pact triggered on loss. balance reset to \$1." >> "$LOG_FILE"
        sleep 1
        echo "your balance has been reset to \$1"
        rm -f "$PACT_FILE"
        sleep 1
        echo "think before you act next time"
        sleep 1
    fi
}

if [[ -f "$BLACKLIST_FILE" ]]; then
    echo "the house remembers."
    echo "you are not welcome here."
    echo
    echo "use: the-house --redeem-my-soul"
    exit 1
fi
