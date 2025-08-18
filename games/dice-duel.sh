#!/bin/bash
# dice-duel.sh

source /usr/lib/the-house/games/common.sh
clear
player_money=$(<"$BALANCE_FILE")

echo "welcome to dice duel: pays 2x"
echo
sleep 0.5

read -r -p "place your bet or 'all' (you have \$$player_money): " bet
if [[ "$bet" == "all" ]]; then
    bet=$player_money
fi
if ! [[ "$bet" =~ ^[0-9]+$ ]] || (( bet > player_money || bet <= 0 )); then
    echo "invalid bet, try again"
    read -n 1 -s -r -p "press any key to return"
    exit 1
fi

player_money=$((player_money - bet))
echo -e "\e[31mbet placed: \$$bet\e[0m"
sleep 0.5

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
    echo -e "\e[32myou win!\e[0m"
    sleep 1
    bet=$(( bet * 2 ))
    player_money=$((player_money + bet))
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
elif (( player_total < house_total )); then
    echo -e "\e[31myou lose\e[0m"
    sleep 1
    echo -e "your new balance: \e[31m\$$player_money\e[0m"
    check_pact_loss
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
else
    echo -e "\e[33mdraw \e[0m"
    sleep 1
    player_money=$((player_money + bet))
    echo -e "your new balance: \e[33m\$$player_money\e[0m"
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
fi

echo "$player_money" > "$BALANCE_FILE"
echo "$(date): dice duel | you: $player_total | house: $house_total | balance: \$$player_money" >> "$LOG_FILE"

