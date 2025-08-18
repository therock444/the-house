#!/bin/bash
# keno.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to keno: pays 2x or 5x"
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

read -r -p "pick 3 numbers between 1 and 10 (space separated): " n1 n2 n3
for n in $n1 $n2 $n3; do
    if (( n < 1 || n > 10 )); then
        echo "invalid pick: $n"
        read -n 1 -s -r -p "press any key to return"
    fi
done

draw1=$(( RANDOM % 10 + 1 ))
draw2=$(( RANDOM % 10 + 1 ))
draw3=$(( RANDOM % 10 + 1 ))

echo "drawing numbers"
sleep 1
echo "draw 1: $draw1"
sleep 1
echo "draw 2: $draw2"
sleep 1
echo "draw 3: $draw3"
sleep 1

matches=0
for pick in $n1 $n2 $n3; do
    if [[ $pick -eq $draw1 || $pick -eq $draw2 || $pick -eq $draw3 ]]; then
        ((matches++))
    fi
done

case $matches in
    3)
        bet=$(( bet * 5 ))
        echo -e "\e[32mall 3 matches, jackpot!\e[0m"
        sleep 1
        echo -e "your new balance: \e[32m\$$player_money\e[0m"
        ;;
    2)
        bet=$(( bet * 2 ))
        echo -e "\e[32mtwo matches! your bet is doubled\e[0m"
        sleep 1
        echo -e "your new balance: \e[32m\$$player_money\e[0m"
        ;;
    1)
        echo -e "\e[33mone match, you break even\e[0m"
        sleep 1
        player_money=$(( player_money + bet ))
        echo -e "your new balance: \e[33m\$$player_money\e[0m"
        ;;
    *)
        bet=0
        echo -e "\e[31mno matches, you lose\e[0m"
        sleep 1
        check_pact_loss
        echo -e "your new balance: \e[31m\$$player_money\e[0m"
        ;;
esac

echo "$player_money" > "$BALANCE_FILE"
sleep 0.5
read -n 1 -s -r -p "press any key to return"

