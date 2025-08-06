#!/bin/bash
# russian-roulette.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to russian roulette"
sleep 1
echo "will you survive?"
sleep 1
echo
read -r -p "place your bet (you have \$$player_money): " bet
if (( bet > player_money || bet <= 0 )); then
    echo "invalid bet, try again"
    exit 1
fi

player_money=$((player_money - bet))

bullet=$(( RANDOM % 6 ))  
trigger=0

read -r -p "pull the trigger? [y/n]: " choice
if [[ "$choice" != "y" ]]; then
    echo "you walk away... for now"
    sleep 2
    exit 0
fi

sleep 1
echo "*click*"
sleep 1

if (( trigger == bullet )); then
    echo "BANG. the house claims another soul."
    echo
    sleep 1
    echo "you are now blacklisted."
    echo "use: the-house --redeem-my-soul"
    sleep 1
    echo "shot during russian roulette" > "$HOME/.config/the-house/blacklist.txt"
    check_pact_loss
else
    echo "you live. for now."
    sleep 1
    echo "the house watches."
    player_money=$((player_money + bet * 2))
    echo "$player_money" > "$BALANCE_FILE"
    sleep 1
    echo "balance doubled, was it worth risking?"
    sleep 1
fi
if (( trigger == bullet )); then
    echo "$(date): russian roulette | LOST | bet: $bet | balance: $player_money" >> "$LOG_FILE"
else
    echo "$(date): russian roulette | SURVIVED | bet: $bet | balance: $player_money" >> "$LOG_FILE"
fi
