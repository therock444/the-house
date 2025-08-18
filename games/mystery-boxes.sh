#!/bin/bash
# mystery-boxes.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to mystery boxes: pick 1 of 8"
echo "2 duds, 2 break even, 2x, 5x, 10x"
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

boxes=(0 0 1 1 2 2 5 10)

for ((i=${#boxes[@]}-1; i>0; i--)); do
    j=$(( RANDOM % (i+1) ))
    tmp=${boxes[i]}
    boxes[i]=${boxes[j]}
    boxes[j]=$tmp
done

shuffled=("${boxes[@]}")

echo
echo "there are 8 mystery boxes in front of you"
read -r -p "chose one (1-8) " choice

if ! [[ "$choice" =~ ^[1-8]$ ]]; then
    echo "invalid choice, try again"
    read -n 1 -s -r -p "press any key to return"
    exit 1
fi

multiplier=${shuffled[$((choice-1))]}
echo
echo "you open box $choice"
sleep 1

case $multiplier in
    0)
        echo -e "\e[31mdud, you lost your bet\e[0m"
        check_pact_loss
        sleep 1
        echo -e "your new balance: \e[31m\$$player_money\e[0m"
        ;;
    1)
        player_money=$(( player_money + bet ))
        echo -e "\e[33mbreak even, bet returned\e[0m"
        sleep 1
        echo -e "your new balance: \e[33m\$$player_money\e[0m"
        ;;
    *)
        winnings=$(( bet * multiplier ))
        player_money=$(( player_money + winnings ))
        echo -e "\e[32mcongratulations, your box was worth ${multiplier}x\e[0m"
        sleep 1
        echo -e "your new balance: \e[32m\$$player_money\e[0m"
        ;;
esac

echo "$player_money" > "$BALANCE_FILE"
sleep 0.5
read -n 1 -s -r -p "press any key to return"

