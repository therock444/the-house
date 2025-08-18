#!/bin/bash
# guess-the-number.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to guess the number: pays 3x"
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

target=$(( RANDOM % 100 + 1 ))

max_attempts=6
attempt=1
echo "i picked a number between 1 and 100. you have 6 tries to guess it"

while (( attempt <= max_attempts )); do
    echo
    read -r -p "attempt $attempt: your guess? " guess

    if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
        echo "please enter a valid number"
        continue
    fi

    if (( guess < 1 || guess > 100 )); then
        echo "guess out of range, try 1 to 100"
        continue
    fi

    if (( guess == target )); then
        echo -e "\e[32mcorrect, you win!\e[0m"
        sleep 1
        player_money=$(( player_money + bet * 3 ))
        echo -e "your new balance: \e[32m\$$player_money\e[0m"
        echo "$player_money" > "$BALANCE_FILE"
        sleep 0.5
        read -n 1 -s -r -p "press any key to return"
        exit 0
    elif (( guess < target )); then
        echo "too low"
    else
        echo "too high"
    fi

    ((attempt++))
done

echo
echo -e "\e[31myou ran out of attempts, it was $target\e[0m"
sleep 1
echo -e "your new balance: \e[31m\$$player_money\e[0m"
check_pact_loss
echo "$player_money" > "$BALANCE_FILE"
sleep 0.5
read -n 1 -s -r -p "press any key to return"
