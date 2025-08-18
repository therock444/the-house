#!/bin/bash
# russian-roulette.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to russian roulette: pays 3x"
sleep 0.5
echo

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
bullet=$(( RANDOM % 3 ))

read -r -p "pull the trigger? [y/n]: " choice
if [[ "$choice" != "y" ]]; then
    echo "you walk away... for now"
    sleep 1
    exit 0
fi

sleep 1
echo "*click*"
sleep 1

trigger=$(( RANDOM % 2 ))

if (( trigger == bullet )); then
    echo -e "\e[31myou got shot, you lose\e[0m"
    echo
    sleep 1
    player_money=50
    echo "$player_money" > "$BALANCE_FILE"
    echo -e "your balance has been set to: \e[31m\$$player_money\e[0m"
    sleep 1
    read -n 1 -s -r -p "press any key to return"
else
    echo "you live"
    sleep 1
    player_money=$((player_money + bet * 3))
    echo "$player_money" > "$BALANCE_FILE"
    sleep 1
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
fi


if (( trigger == bullet )); then
    echo "$(date): russian roulette | LOST | bet: $bet | balance: $player_money" >> "$LOG_FILE"
else
    echo "$(date): russian roulette | SURVIVED | bet: $bet | balance: $player_money" >> "$LOG_FILE"
fi
