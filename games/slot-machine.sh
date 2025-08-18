#!/bin/bash
# slot-machine.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to the slot machine, pays 2x or 5x"
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

symbols=(1 2 3 4 5 6 7)
reel1=${symbols[$RANDOM % ${#symbols[@]}]}
reel2=${symbols[$RANDOM % ${#symbols[@]}]}
reel3=${symbols[$RANDOM % ${#symbols[@]}]}

echo "spinning"
sleep 1
printf "[ "
printf "%s" "$reel1"
sleep 1
printf "  %s" "$reel2"
sleep 1
printf "  %s" "$reel3"
printf " ]\n"
sleep 1

win=0
if (( reel1 == reel2 && reel2 == reel3 )); then
    win=$(( bet * 5 ))
    echo -e "\e[32mjackpot, you win 5x your bet!\e[0m"
    sleep 1
elif (( reel1 == reel2 || reel2 == reel3 || reel1 == reel3 )); then
    win=$(( bet * 2))
    echo -e "\e[32mtwo of a kind, you win double!\e[0m"
    sleep 1
fi

if (( win > 0 )); then
    player_money=$(( player_money + win ))
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
else
    echo -e "\e[31mno matches, you lose\e[0m"
    sleep 1
    check_pact_loss
    echo -e "your new balance: \e[31m\$$player_money\e[0m"
fi
sleep 0.5
echo "$player_money" > "$BALANCE_FILE"
read -n 1 -s -r -p "press any key to return"
