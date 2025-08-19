#!/bin/bash
# plinko.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to plinko: pays 1-5x"
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

slots = (0 2 0 1 0 1 0 2 0)

position=$(( ${#slots[@]} / 2 ))

rows=10 

echo
echo "dropping the ball"
sleep 1

for ((row=1; row<=rows; row++)); do
    move=$((RANDOM % 2))
    if (( move == 0 )); then
       ((position--))
    else
       ((position++))
    fi
    
    if (( position < 0 )); then
        position=0
    elif (( position >= ${#slots[@]} )); then
        position=$((${#slots[@]} - 1))
    fi

    for ((i=0; i<${#slots[@]}; i++)); do
        if (( i == position )); then
            printf "o "
        else
            printf ". "
        fi
    done
    echo
    sleep 0.3
done


multiplier=${slots[$position]}
if (( multiplier > 0 )); then
    win_amount=$(( bet * multiplier ))
    player_money=$((player_money + win_amount))
    echo -e "\e[32myou landed in slot $position, payout: ${multiplier}x -> \$$win_amount\e[0m"
    sleep 1
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
else
    echo -e "\e[31myou landed in slot $position, no payout\e[0m"
    sleep 1
    echo -e "your new balance: \e[31m\$$player_money\e[0m"
    check_pact_loss
fi

echo "$player_money" > "$BALANCE_FILE"

sleep 0.5
read -n 1 -s -r -p "press any key to return"

