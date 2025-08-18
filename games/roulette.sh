#!/bin/bash
# roulette.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to roulette: pays 2x, 3x, or 10x"
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

echo
echo "choose bet type:"
echo "1) number bet (1-10, pays 10x)"
echo "2) even/odd bet (pays 2x)"
echo "3) high/low bet (1-5 low, 6-10 high, pays 2x)"
echo "4) dozen bet (1-3, 4-7, 8-10, pays 3x)"
echo
read -r -p ">> " bet_type

case "$bet_type" in
    1)
        read -r -p "choose your number (1-10): " chosen_number
        if ! [[ "$chosen_number" =~ ^[0-9]+$ ]] || (( chosen_number < 1 || chosen_number > 10 )); then
            echo "invalid number"
            sleep 1
            exit 1
        fi
        ;;
    2)
        read -r -p "bet on (even/odd): " chosen_type
        chosen_type=$(echo "$chosen_type" | tr '[:upper:]' '[:lower:]')
        if [[ "$chosen_type" != "even" && "$chosen_type" != "odd" ]]; then
            echo "invalid choice"
            sleep 1
            exit 1
        fi
        ;;
    3)
        read -r -p "bet on (high/low): " chosen_type
        chosen_type=$(echo "$chosen_type" | tr '[:upper:]' '[:lower:]')
        if [[ "$chosen_type" != "high" && "$chosen_type" != "low" ]]; then
            echo "invalid choice"
            sleep 1
            exit 1
        fi
        ;;
    4)
        read -r -p "choose dozen (1-3, 4-7, 8-10): " chosen_dozen
        if ! [[ "$chosen_dozen" =~ ^(1-3|4-7|8-10)$ ]]; then
    	echo "invalid dozen"
    	sleep 1
    	exit 1
	fi
        ;;
    *)
        echo "invalid choice"
        sleep 1
        exit 1
        ;;
esac

wheel=(1 2 3 4 5 6 7 8 9 10)

get_color() {
    local num=$1
    case "$bet_type" in
        1)
            [[ "$num" -eq "$chosen_number" ]] && echo 32 || echo 31 ;;
        2)
            if [[ "$chosen_type" == "even" && $((num % 2)) -eq 0 ]] || \
               [[ "$chosen_type" == "odd" && $((num % 2)) -ne 0 ]]; then
                echo 32
            else
                echo 31
            fi ;;
        3)
            if [[ "$chosen_type" == "low" && "$num" -le 5 ]] || \
               [[ "$chosen_type" == "high" && "$num" -ge 6 ]]; then
                echo 32
            else
                echo 31
            fi ;;
        4)
            case "$chosen_dozen" in
                1-3) [[ "$num" -ge 1 && "$num" -le 3 ]] && echo 32 || echo 31 ;;
                4-7) [[ "$num" -ge 4 && "$num" -le 7 ]] && echo 32 || echo 31 ;;
                8-10) [[ "$num" -ge 8 && "$num" -le 10 ]] && echo 32 || echo 31 ;;
            esac ;;
        *)
            echo 31 ;;
    esac
}

for ((i=${#wheel[@]}-1; i>0; i--)); do
    j=$(( RANDOM % (i+1) ))
    temp=${wheel[i]}
    wheel[i]=${wheel[j]}
    wheel[j]=$temp
done

spins=$(( RANDOM % 20 + 15 ))
pos=0
for ((i=0; i<spins; i++)); do
    clear
    echo "spinning the roulette wheel:"
    for ((j=0; j<${#wheel[@]}; j++)); do
    index=$(( (pos + j) % ${#wheel[@]} ))
    if (( j == 0 )); then
        color=$(get_color "${wheel[index]}")  # only color the ball
        echo -ne "> \e[${color}m${wheel[index]}\e[0m  "
    else
        echo -ne "${wheel[index]}  "  # other numbers stay default
    fi
done
    echo
    sleep 0.15
    pos=$(( (pos + 1) % ${#wheel[@]} ))
done

final_pos=$(( (pos - 1 + ${#wheel[@]}) % ${#wheel[@]} ))
result=${wheel[final_pos]}
result_color=$(get_color "$result")

echo
echo -e "the ball landed on: \e[${result_color}m$result\e[0m"

final_pos=$(( (pos - 1 + ${#wheel[@]}) % ${#wheel[@]} ))
result=${wheel[final_pos]}
result_color=$(get_color "$result")

case "$bet_type" in
    1) (( result == chosen_number )) && winnings=$(( bet * 10 )) || winnings=0 ;;
    2) (( (chosen_type == "even" && result % 2 == 0) || (chosen_type == "odd" && result % 2 != 0) )) && winnings=$(( bet * 2 )) || winnings=0 ;;
    3) (( (chosen_type == "low" && result <= 5) || (chosen_type == "high" && result >= 6) )) && winnings=$(( bet * 2 )) || winnings=0 ;;
    4)
        case "$chosen_dozen" in
            1-3) (( result >= 1 && result <= 3 )) && winnings=$(( bet * 3 )) || winnings=0 ;;
            4-7) (( result >= 4 && result <= 7 )) && winnings=$(( bet * 3 )) || winnings=0 ;;
            8-10) (( result >= 8 && result <= 10 )) && winnings=$(( bet * 3 )) || winnings=0 ;;
        esac ;;
esac

if (( winnings > 0 )); then
    echo -e "\e[32myou win!\e[0m"
    player_money=$(( player_money + winnings ))
    sleep 1
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
else
    echo -e "\e[31myou lost!\e[0m"
    check_pact_loss
    sleep 1
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
fi

echo "$player_money" > "$BALANCE_FILE"
sleep 0.5
read -n 1 -s -r -p "press any key to return"

