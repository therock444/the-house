#!/bin/bash
# card-draw.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to card draw: higher card wins, pays 2x"
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

player_money=$(( player_money - bet ))
echo -e "\e[31mbet placed: \$$bet\e[0m"
sleep 0.5

player_card=$(( RANDOM % 13 + 1 ))
house_card=$(( RANDOM % 13 + 1 ))

card_names=( "" "A" "2" "3" "4" "5" "6" "7" "8" "9" "10" "J" "Q" "K" )

echo
echo -e "you drew:   \e[36m${card_names[$player_card]} ($player_card)\e[0m"
sleep 1
echo -e "the house:  \e[35m${card_names[$house_card]} ($house_card)\e[0m"
echo
sleep 1

if (( player_card > house_card )); then
    player_money=$(( player_money + bet * 2 ))
    echo -e "\e[32myou win! \e[0m"
    sleep 1
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
elif (( player_card < house_card )); then
    echo -e "\e[31myou lost your bet!\e[0m"
    check_pact_loss
else
    player_money=$(( player_money + bet ))
    echo -e "\e[33mdraw\e[0m"
    sleep 1
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
fi

echo "$player_money" > "$BALANCE_FILE"
sleep 0.5
read -n 1 -s -r -p "press any key to return"
