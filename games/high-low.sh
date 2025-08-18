#!/bin/bash
# high-low.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to high-low: pays 2x"
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
current_card=$(( RANDOM % 13 + 1 ))
echo
echo "starting card is $current_card"

read -r -p "will the next card be higher or lower? (h/l): " guess
if [[ ! "$guess" =~ ^[hlHL]$ ]]; then
    echo "invalid input"
    read -n 1 -s -r -p "press any key to return"
    break
fi

next_card=$(( RANDOM % 13 + 1 ))
echo "next card is $next_card"

win=0
if [[ "$guess" =~ ^[hH]$ && next_card -gt current_card ]]; then
    win=1
elif [[ "$guess" =~ ^[lL]$ && next_card -lt current_card ]]; then
    win=1
fi

if (( win )); then
    echo -e "\e[32myou win!\e[0m"
    sleep 1
    player_money=$(( player_money + bet * 2))
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
else
    echo -e "\e[31myou lose\e[0m"
    sleep 1
    echo -e "your new balance: \e[31m\$$player_money\e[0m"
    check_pact_loss
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
fi

echo "$player_money" > "$BALANCE_FILE"
