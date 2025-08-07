#!/bin/bash
# coinflip.sh

source /usr/lib/the-house/games/common.sh

clear
echo "welcome to coinflip"
sleep 1
read -r -p "place your bet (you have \$$player_money): " bet

if (( bet > player_money || bet <= 0 )); then
    echo "invalid bet, try again"
    exit 1
fi

player_money=$((player_money - bet))

read -rp "heads or tails? [h/t]: " choice
if [[ "$choice" != "h" && "$choice" != "t" ]]; then
    echo "invalid choice"
    exit 1
fi

echo "flipping the coin"
sleep 1
flip=$(( RANDOM % 2 ))
[[ "$flip" -eq 0 ]] && result="h" || result="t"

if [[ "$choice" == "$result" ]]; then
    echo "you win the flip"
    player_money=$((player_money + bet * 2))
    sleep 1
    echo "your new balance: \$$player_money"
    sleep 1
    read -n 1 -s -r -p "press any key to return"
else
    echo "you lose the flip"
    sleep 1
    echo "your new balance: \$$player_money"
    check_pact_loss
    sleep 1
    read -n 1 -s -r -p "press any key to return"
fi

echo "$player_money" > "$BALANCE_FILE"
echo "$(date): coin flip | choice: $choice | result: $result | balance: \$$player_money" >> "$LOG_FILE"

