#!/bin/bash
# wheel-of-fortune.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to wheel of fortune"
echo "payouts: 1-10X"
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

wheel=(L L L B B B X2 X2 X2 X5 X10)

for ((i=${#wheel[@]}-1; i>0; i--)); do # me when no shuf
    j=$(( RANDOM % (i+1) ))
    tmp=${wheel[i]}
    wheel[i]=${wheel[j]}
    wheel[j]=$tmp
done

colors=()
for slot in "${wheel[@]}"; do
    case $slot in
        L) colors+=(31) ;;  
        B) colors+=(33) ;;   
        *) colors+=(32) ;;   
    esac
done

spins=$(( RANDOM % 15 + 15 ))
pos=0

for ((i=0;i<spins;i++)); do
    clear
    echo "spinning the wheel:"
    for ((j=0;j<${#wheel[@]};j++)); do
        index=$(( (pos + j) % ${#wheel[@]} ))
        if (( j == 0 )); then
            echo -ne "> \e[${colors[index]}m${wheel[index]}\e[0m  "
        else
            echo -ne "${wheel[index]}  "
        fi
    done
    echo
    sleep 0.1
    pos=$(( (pos + 1) % ${#wheel[@]} ))
done

final_pos=$(( (pos - 1 + ${#wheel[@]}) % ${#wheel[@]} ))
result=${wheel[final_pos]}

case $result in
    L)
        echo -e "\e[31mwheel landed on lose\e[0m"
        sleep 1
        check_pact_loss
        echo -e "your new balance: \e[31m\$$player_money\e[0m"
        ;;
    B)
        echo -e "\e[33mwheel landed on break even\e[0m"
        player_money=$(( player_money + bet ))
        sleep 1
        echo -e "your new balance: \e[33m\$$player_money\e[0m"
        ;;
    X2)
        echo -e "\e[32mwheel landed on 2x!\e[0m"
        player_money=$(( player_money + bet * 2 ))
        sleep 1
        echo -e "your new balance: \e[32m\$$player_money\e[0m"
        ;;
    X5)
        echo -e "\e[32mwheel landed on 5x!\e[0m"
        player_money=$(( player_money + bet * 5 ))
        sleep 1
        echo -e "your new balance: \e[32m\$$player_money\e[0m"
        ;;
    X10)
        echo -e "\e[32mwheel landed on 10x!!\e[0m"
        player_money=$(( player_money + bet * 10 ))
        echo -e "you win: \e[32m\$$(( bet * 10 ))\e[0m"
        sleep 1
        echo -e "your new balance: \e[32m\$$player_money\e[0m"
        ;;
esac

echo "$player_money" > "$BALANCE_FILE"
sleep 0.5
read -n 1 -s -r -p "press any key to return"

