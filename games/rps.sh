#!/bin/bash
# rps.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to rock paper scissors: pays 2x"
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

echo
echo "choose your move:"
echo "1) rock"
echo "2) paper"
echo "3) scissors"
read -r -p ">> " player_choice

if [[ ! "$player_choice" =~ ^[1-3]$ ]]; then
    echo "invalid input"
    read -n 1 -s -r -p "press any key to return"
    exit 1
fi

moves=("rock" "paper" "scissors")
player_move=${moves[$((player_choice-1))]}

house_choice=$(( RANDOM % 3 ))
house_move=${moves[$house_choice]}

echo
echo "you chose $player_move"
sleep 1
echo "house chose $house_move"
sleep 0.5

win=0
tie=0
if (( player_choice-1 == house_choice )); then
    tie=1
elif (( (player_choice-1 == 0 && house_choice == 2) ||
        (player_choice-1 == 1 && house_choice == 0) ||
        (player_choice-1 == 2 && house_choice == 1) )); then
    win=1
fi

if (( tie )); then
    echo -e "\e[33mdraw\e[0m"
    sleep 1
    player_money=$(( player_money + bet )) 
    echo -e "your new balance: \e[33m\$$player_money\e[0m"
elif (( win )); then
    echo -e "\e[32myou win!\e[0m"
    sleep 1
    player_money=$(( player_money + bet * 2 ))
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
else
    echo -e "\e[31myou lose!\e[0m"
    sleep 1
    echo -e "your new balance: \e[31m\$$player_money\e[0m"
    check_pact_loss
fi

sleep 0.5
read -n 1 -s -r -p "press any key to return"

echo "$player_money" > "$BALANCE_FILE"
