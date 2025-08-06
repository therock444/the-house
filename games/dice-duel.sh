#!/bin/bash
# dice-duel.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

player_money=$(<"$BALANCE_FILE")
echo "welcome to dice duel"
sleep 1
clear
read -r -p "place your bet (you have \$$player_money): " bet

if (( bet > player_money || bet <= 0 )); then
    echo "invalid bet, try again"
    exit 1
fi

player_money=$((player_money - bet))

echo "you roll.."
sleep 1
player_die1=$(( RANDOM % 6 + 1 ))
player_die2=$(( RANDOM % 6 + 1 ))
player_total=$((player_die1 + player_die2))
echo "you: $player_die1 + $player_die2 = $player_total"

sleep 1
echo "the house rolls.."
sleep 1
house_die1=$(( RANDOM % 6 + 1 ))
house_die2=$(( RANDOM % 6 + 1 ))
house_total=$((house_die1 + house_die2))
echo "house: $house_die1 + $house_die2 = $house_total"

if (( player_total > house_total )); then
    echo "you win the duel"
    sleep 2
    player_money=$((player_money + bet * 2))
elif (( player_total < house_total )); then
    echo "the house wins"
    sleep 2
    check_pact_loss
else
    echo "draw"
    sleep 2
    player_money=$((player_money + bet))
fi

echo "$player_money" > "$BALANCE_FILE"
echo "$(date): dice duel | you: $player_total | house: $house_total | balance: \$$player_money" >> "$LOG_FILE"

