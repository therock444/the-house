#!/bin/bash
# blackjack.sh

ggez=false
source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

deck=(2 3 4 5 6 7 8 9 10 J Q K A)
get_value() {
    case "$1" in
        J|Q|K) echo 10 ;;
        A) echo 11 ;; 
        *) echo "$1" ;;
    esac
}

draw_card() {
    echo "${deck[$RANDOM % ${#deck[@]}]}"
}

calc_total() {
    total=0
    aces=0
    for card in "$@"; do
        val=$(get_value "$card")
        (( total += val ))
        [[ "$card" == "A" ]] && (( aces++ ))
    done

    while (( total > 21 && aces > 0 )); do
        (( total -= 10 ))
        (( aces-- ))
    done

    echo $total
}

player_hand=()
dealer_hand=()
dealer_total=""

echo "welcome to blackjack: pays 2x or 3x"
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
player_hand+=("$(draw_card)" "$(draw_card)")
dealer_hand+=("$(draw_card)" "$(draw_card)")
echo -e "\e[31mbet placed: \$$bet\e[0m"
sleep 0.5

while true; do
    player_total=$(calc_total "${player_hand[@]}")
    dealer_shown="${dealer_hand[0]}"
    
    echo -e "\nyour hand: ${player_hand[*]} (total: $player_total)"
    echo "dealer shows: $dealer_shown"

    if (( player_total == 21 )); then
    	echo -e "\e[32mblackjack! you win triple!\e[0m"
    	sleep 1
    	player_money=$((player_money + bet * 3))
    	echo "$player_money" > "$BALANCE_FILE"
    	ggez=true 
    	echo -e "your new balance: \e[32m\$$player_money\e[0m"
    	sleep 0.5
    	read -n 1 -s -r -p "press any key to return"
    	break
    elif (( player_total > 21 )); then
        echo -e "\e[31mbust, you lose\e[0m"
        sleep 1
        echo "$player_money" > "$BALANCE_FILE"
        echo -e "your new balance: \e[31m\$$player_money\e[0m"
        ggez=true
        check_pact_loss
        sleep 0.5
        read -n 1 -s -r -p "press any key to return"
        break
    fi

read -r -p "hit, stand, or double down? [h/s/d]: " choice
if [[ "$choice" == "s" ]]; then
    break

elif [[ "$choice" == "h" ]]; then
    new_card="$(draw_card)"
    player_hand+=("$(draw_card)")
    player_total=$(calc_total "${player_hand[@]}")
    if (( player_total > 21 )); then
        sleep 0.5
        echo -e "\e[31mbust, you lose\e[0m"
        sleep 1
        echo "$player_money" > "$BALANCE_FILE"
        echo -e "your new balance: \e[31m\$$player_money\e[0m"
        ggez=true
        check_pact_loss
        sleep 0.5
        read -n 1 -s -r -p "press any key to return"
        break
    fi

elif [[ "$choice" == "d" ]]; then
    bet=$(( bet * 2 ))
    player_hand+=("$(draw_card)")
    player_total=$(calc_total "${player_hand[@]}")
    echo "you draw: ${player_hand[-1]} (total: $player_total)"
    if (( player_total > 21 )); then
        echo -e "\e[31mbust, you lose\e[0m"
        sleep 1
        echo "$player_money" > "$BALANCE_FILE"
        echo -e "your new balance: \e[31m\$$player_money\e[0m"
        ggez=true
        check_pact_loss
        sleep 0.5
        read -n 1 -s -r -p "press any key to return"
    fi
    break 

else
    echo "invalid choice. it's a simple [h]it, [s]tand, or [d]ouble down genius"
fi
done

if [[ "$ggez" != true ]]; then
echo
echo -e "\ndealers turn"
dealer_total=$(calc_total "${dealer_hand[@]}")
echo "dealers hand: ${dealer_hand[*]} (total: $dealer_total)"

while (( ${dealer_total:-0} < 17 )); do
    sleep 1
    dealer_hand+=("$(draw_card)")
    dealer_total=$(calc_total "${dealer_hand[@]}")
    echo
    echo "dealer hits: ${dealer_hand[*]} (total: $dealer_total)"

    if (( dealer_total == player_total )); then
        if (( RANDOM % 10 == 0 )); then
            echo "the dealer cant find his secret ace to cheat"
        else
            dealer_hand+=("A") # shhh dont tell anyone
            dealer_total=$(calc_total "${dealer_hand[@]}")
        fi
    fi
done
fi

if [[ "$ggez" != true ]]; then
sleep 0.5
echo -e "\nfinal hands:"
echo "you: ${player_hand[*]} (total: $player_total)"
sleep 1
echo "dealer: ${dealer_hand[*]} (total: $dealer_total)"
echo
if (( dealer_total > 21 )); then
    sleep 1
    echo -e "\e[32mdealer busts, you win!\e[0m"
    sleep 1
    player_money=$((player_money + bet * 2))
    echo "$player_money" > "$BALANCE_FILE"
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
elif (( player_total > dealer_total )); then
    sleep 1
    echo -e "\e[32myou win!\e[0m"
    sleep 1
    player_money=$((player_money + bet * 2))
    echo "$player_money" > "$BALANCE_FILE"
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
elif (( player_total < dealer_total )); then
    echo -e "\e[31myou lose\e[0m"
    sleep 1
    echo "$player_money" > "$BALANCE_FILE"
    echo -e "your new balance: \e[31m\$$player_money\e[0m"
    check_pact_loss
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
else
    echo -e "\e[33myou lose\e[0m"
    sleep 1
    player_money=$((player_money + bet))
    echo "$player_money" > "$BALANCE_FILE"
    echo -e "your new balance: \e[33m\$$player_money\e[0m"
    sleep 0.5
    read -n 1 -s -r -p "press any key to return"
fi
fi
echo "$(date): you: ${player_hand[*]} ($player_total) | dealer: ${dealer_hand[*]} ($dealer_total) | balance: \$$player_money" >> "$LOG_FILE"
