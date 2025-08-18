#!/bin/bash
# dice-pyramid.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to dice pyramid: pays 2x per round"
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

round=1
dice_count=1

while true; do
    echo
    echo -e "\e[36mround $round: rolling $dice_count dice\e[0m"
    roll_sum=0
    for (( i=1; i<=dice_count; i++ )); do
        roll=$(( RANDOM % 6 + 1 ))
        echo -n "$roll "
        roll_sum=$(( roll_sum + roll ))
    done
    echo
    sleep 0.5

    threshold=$(( dice_count * 3 ))
    if (( roll_sum < threshold )); then
        echo -e "\e[31myou rolled $roll_sum (below $threshold) and lost!\e[0m"
        check_pact_loss
        sleep 1
        echo -e "your new balance: \e[31m\$$player_money\e[0m"
        echo "$player_money" > "$BALANCE_FILE"
        sleep 0.5
        read -n 1 -s -r -p "press any key to return"
        exit 0
    else
        winnings=$(( bet * 2 ** (round-1) ))
        echo -e "\e[32myou rolled $roll_sum (threshold $threshold), round won\e[0m"
        echo -e "current potential winnings: \e[32m\$$winnings\e[0m"
        read -r -p "roll next round or cash out? (r/c): " choice
        case "$choice" in
            r|R)
                (( round++ ))
                (( dice_count++ ))
                continue
                ;;
            c|C)
                player_money=$(( player_money + winnings ))
                echo -e "\e[32myou cashed out\e[0m"
                sleep 1
                echo -e "your new balance: \e[32m\$$player_money\e[0m"
                echo "$player_money" > "$BALANCE_FILE"
                sleep 0.5
                read -n 1 -s -r -p "press any key to return"
                exit 0
                ;;
            *)
                echo "invalid choice, cashing out"
                player_money=$(( player_money + winnings ))
                echo "$player_money" > "$BALANCE_FILE"
                sleep 1
                exit 0
                ;;
        esac
    fi
done

