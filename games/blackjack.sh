#!/bin/bash
# blackjack.sh

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

echo "welcome to hell (blackjack)"
read -r -p "place your bet (you have \$$player_money): " bet
if (( bet > player_money || bet <= 0 )); then
    echo "invalid bet, try again"
    exit 1
fi
player_money=$((player_money - bet))
player_hand+=("$(draw_card)" "$(draw_card)")
dealer_hand+=("$(draw_card)" "$(draw_card)")

while true; do
    player_total=$(calc_total "${player_hand[@]}")
    dealer_shown="${dealer_hand[0]}"
    
    echo -e "\nyour hand: ${player_hand[*]} (total: $player_total)"
    echo "dealer shows: $dealer_shown"

# debug remanants, if youre here wanting to cheat that much, here you go what can i say
#    echo "[debug] cheating and setting players hand to 21 (fun)"
#    sleep 1
#    player_total=21
#    player_hand=("A" "K")
    if (( player_total == 21 )); then
    	echo "blackjack, you win!"
    	sleep 1
    	player_money=$((player_money + bet * 2))
    	echo "$player_money" > "$BALANCE_FILE"
    	ggez=true 
    	break
    elif (( player_total > 21 )); then
        echo "bust, you lose!"
        echo "$player_money" > "$BALANCE_FILE"
        echo "you now have $player_money"
        check_pact_loss
        read -n 1 -s -r -p "press any key to return"
        break
    fi

    read -r -p "hit or stand? [h/s]: " choice
    if [[ "$choice" == "s" ]]; then
        break
    elif [[ "$choice" == "h" ]]; then
        player_hand+=("$(draw_card)")
    else
        echo "invalid choice. it's a simple [h]it or [s]tand genius"
    fi
done

if [[ "$ggez" != true ]]; then
echo -e "\ndealers turn"
dealer_total=$(calc_total "${dealer_hand[@]}")
echo "dealers hand: ${dealer_hand[*]} (total: $dealer_total)"

while (( ${dealer_total:-0} < 17 )); do
    sleep 1
    dealer_hand+=("$(draw_card)")
    dealer_total=$(calc_total "${dealer_hand[@]}")
    echo "dealer hits: ${dealer_hand[*]} (total: $dealer_total)"

    if (( dealer_total == player_total )); then
        if (( RANDOM % 10 == 0 )); then
            echo "dealer hesitates and lets it be a draw"
        else
            dealer_hand+=("A") # shhh dont tell anyone
            dealer_total=$(calc_total "${dealer_hand[@]}")
        fi
    fi
done
fi

if [[ "$ggez" != true ]]; then
echo -e "\nfinal hands:"
echo "you: ${player_hand[*]} (total: $player_total)"
echo "dealer: ${dealer_hand[*]} (total: $dealer_total)"

if (( dealer_total > 21 )); then
    echo "dealer busts, you win!"
    player_money=$((player_money + bet * 2))
    echo "$player_money" > "$BALANCE_FILE"
    echo "you now have $player_money"
    read -n 1 -s -r -p "press any key to return"
elif (( player_total > dealer_total )); then
    echo "you win!"
    player_money=$((player_money + bet * 2))
    echo "$player_money" > "$BALANCE_FILE"
    echo "you now have $player_money"
    read -n 1 -s -r -p "press any key to return"
elif (( player_total < dealer_total )); then
    echo "dealer wins!"
    echo "$player_money" > "$BALANCE_FILE"
    echo "you now have $player_money"
    check_pact_loss
    read -n 1 -s -r -p "press any key to return"
else
    echo "draw"
    player_money=$((player_money + bet))
    echo "$player_money" > "$BALANCE_FILE"
    echo "you now have $player_money"
fi
fi
echo "$(date): you: ${player_hand[*]} ($player_total) | dealer: ${dealer_hand[*]} ($dealer_total) | balance: \$$player_money" >> "$LOG_FILE"
