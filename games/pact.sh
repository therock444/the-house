#!/bin/bash
# pact.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

if [[ -f "$PACT_FILE" ]]; then
    echo "youve already signed the pact"
    echo "bit greedy, dont ya think?"
    exit 1
fi

player_money=$(<"$BALANCE_FILE")
echo "the pact is offered to you."
sleep 1
echo "your balance will be multiplied by 5..."
sleep 1
echo "but one loss, and your balance is set to 10 measly dollars"
read -r -p "do you accept the pact? [y/n]: " choice

if [[ "$choice" != "y" ]]; then
    echo "you walk away. the house watches."
    exit 0
fi

player_money=$((player_money * 5))
echo "$player_money" > "$BALANCE_FILE"

timestamp=$(date)
echo "$timestamp: pact accepted | balance: $player_money" >> "$LOG_FILE"

echo "your balance is now \$$player_money."
echo "$(date) --- signed the pact" > "$PACT_FILE"
sleep 1
echo "watch your back"
sleep 3
exit 0
