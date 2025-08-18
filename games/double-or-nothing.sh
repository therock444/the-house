#!/bin/bash
# double-or-nothing.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to double or nothing: pays 2x, increments"
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
while true; do
    echo
    echo -e "\e[36mround $round: do you risk it?\e[0m"
    echo -e "current winnings: \e[32m\$$(($bet * 2 ** (round-1)))\e[0m"
    echo
    read -r -p "double or cash out? (d/c): " choice
    case "$choice" in
        d|D)
            echo "double chosen"
            sleep 1
            if (( RANDOM % 2 == 0 )); then
                echo -e "\e[32myou won this round!\e[0m"
                ((round++))
                continue
            else
                echo -e "\e[31myou lost everything!\e[0m"
                check_pact_loss
                echo -e "your new balance: \e[31m\$$player_money\e[0m"
                echo "$player_money" > "$BALANCE_FILE"
                sleep 0.5
                read -n 1 -s -r -p "press any key to return"
                exit 0
            fi
            ;;
        c|C)
            winnings=$(( bet * 2 ** (round-1) ))
            player_money=$(( player_money + winnings ))
            echo -e "\e[32myou cashed out with \$$winnings!\e[0m"
            echo -e "your new balance: \e[32m\$$player_money\e[0m"
            echo "$player_money" > "$BALANCE_FILE"
            sleep 0.5
            read -n 1 -s -r -p "press any key to return"
            exit 0
            ;;
        *)
            echo "invalid choice, try again"
            ;;
    esac
done

