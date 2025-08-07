#!/bin/bash
# dice-duel.sh

source /usr/lib/the-house/games/common.sh
clear
player_money=$(<"$BALANCE_FILE")
echo "welcome to dice duel"
sleep 1
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
    sleep 1
    player_money=$((player_money + bet * 2))
elif (( player_total < house_total )); then
    echo "the house (always) wins"
    sleep 1
    echo "you now have $player_money"
    check_pact_loss
    read -n 1 -s -r -p "press any key to return"
else
    echo "draw"
    sleep 1
    player_money=$((player_money + bet))
    echo "you now have $player_money"
    read -n 1 -s -r -p "press any key to return"
fi

echo "$player_money" > "$BALANCE_FILE"
echo "$(date): dice duel | you: $player_total | house: $house_total | balance: \$$player_money" >> "$LOG_FILE"

