#!/bin/bash
# stock-market.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to the stock market"
echo
sleep 0.5

echo "choose your asset:"
echo "1) bitcoin (high risk, +/-40-60% per tick)"
echo "2) ethereum (medium risk, +/-20-40% per tick)"
echo "3) litecoin (low risk, +/-5-15% per tick)"
read -r -p "pick: " asset_choice

case $asset_choice in
    1) min_change=40; max_change=60 ;;
    2) min_change=20; max_change=40 ;;
    3) min_change=5;  max_change=15 ;;
    *) echo "invalid choice"; read -n 1 -s -r -p "press any key to return"; exit 1 ;;
esac

read -r -p "place your investment or 'all' (you have \$$player_money): " investment
if [[ "$investment" == "all" ]]; then
    investment=$player_money
fi
if ! [[ "$investment" =~ ^[0-9]+$ ]] || (( investment > player_money || investment <= 0 )); then
    echo "invalid investment, try again"
    read -n 1 -s -r -p "press any key to return"
    exit 1
fi

player_money=$(( player_money - investment ))
echo -e "\e[33minvested: \$$investment\e[0m"
sleep 0.5

current_value=$investment
running=true

echo
echo "press 'c' to cash out when ready"

while $running; do
    for i in {1..20}; do 
        read -t 0.1 -n 1 choice
        if [[ "$choice" == "c" ]]; then
            player_money=$(( player_money + current_value ))
            echo
            if (( current_value < investment )); then
                echo -e "\e[31myou cashed out with \$$current_value\e[0m"
                sleep 1
                echo -e "your new balance: \e[31m\$$player_money\e[0m"
                sleep 0.5
                read -n 1 -s -r -p "press any key to return"
            else
                echo -e "\e[32myou cashed out with \$$current_value!\e[0m"
                sleep 1
                echo -e "your new balance: \e[32m\$$player_money\e[0m"
                sleep 0.5
                read -n 1 -s -r -p "press any key to return"
            fi
            echo "$player_money" > "$BALANCE_FILE"
            running=false
            break 2
        fi
        sleep 0.03
    done
    
    change_percent=$(( RANDOM % (max_change - min_change + 1) + min_change ))

    if (( RANDOM % 2 == 0 )); then
        current_value=$(( current_value * (100 - change_percent) / 100 ))
        echo -e "\e[31mstock dropped $change_percent% → now worth \$$current_value\e[0m"
    else
        current_value=$(( current_value * (100 + change_percent) / 100 ))
        echo -e "\e[32mstock rose $change_percent% → now worth \$$current_value\e[0m"
    fi
done
