#!/bin/bash
# scratch-card.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to scratch card: pays 2x or 5x"
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

card=()
for i in {1..3}; do
    card+=($(( RANDOM % 5 + 1 )))
done

echo
echo "scratching your card"
sleep 1
printf "%s " "${card[0]}"
sleep 1
printf "%s " "${card[1]}"
sleep 1
printf "%s\n" "${card[2]}"
sleep 1
echo

if [[ ${card[0]} -eq ${card[1]} && ${card[1]} -eq ${card[2]} ]]; then
    sleep 1
    echo -e "\e[36mjackpot, you win 5x your bet!\e[0m"
    sleep 1
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
    player_money=$(( player_money + bet * 5 ))
elif [[ ${card[0]} -eq ${card[1]} || ${card[0]} -eq ${card[2]} || ${card[1]} -eq ${card[2]} ]]; then
    sleep 1
    echo -e "\e[32mtwo matches, you win 2x your bet!\e[0m"
    sleep 1
    player_money=$(( player_money + bet * 2 ))
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
else
    echo -e "\e[31mno matches, you lose\e[0m"
    sleep 1
    check_pact_loss
    echo -e "your new balance: \e[31m\$$player_money\e[0m"
fi

echo "$player_money" > "$BALANCE_FILE"

sleep 0.5
read -n 1 -s -r -p "press any key to return"

