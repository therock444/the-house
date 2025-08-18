#!/bin/bash
# minesweeper.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to minesweeper: pays 2x, increments"
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

rows=3
cols=3
mines=$(( RANDOM % 3 + 2 ))
grid_size=$(( rows * cols ))

mine_positions=()
while (( ${#mine_positions[@]} < mines )); do
    pos=$(( RANDOM % grid_size ))
    [[ " ${mine_positions[*]} " == *" $pos "* ]] || mine_positions+=("$pos")
done

revealed=()
safe_picks=0
current_multiplier=1

echo
echo -e "the board has $((rows*cols)) tiles, \e[31m$mines\e[0m of them are mines"
sleep 0.5
echo "hit a mine and you lose it all"
sleep 1

while (( safe_picks < grid_size - mines )); do
    echo
    echo -e "current multiplier: \e[32m${current_multiplier}x\e[0m"
    echo -e "current potential winnings: \e[32m\$${bet} * ${current_multiplier} = $(( bet * current_multiplier ))\e[0m"
    read -r -p "pick a tile 1-$grid_size or type c to cash out > " choice

    if [[ "$choice" =~ ^[Cc]$ ]]; then
        winnings=$(( bet * current_multiplier ))
        player_money=$(( player_money + winnings ))
        echo -e "\e[32mcashed out!"
        echo -e "your new balance: \e[32m\$$player_money\e[0m"
        echo "$player_money" > "$BALANCE_FILE"
        read -n 1 -s -r -p "press any key to return"
        exit 0
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > grid_size )); then
        echo "invalid choice"
        continue
    fi
    if [[ " ${revealed[*]} " == *" $choice "* ]]; then
        echo "already picked"
        continue
    fi

    revealed+=("$choice")
    tile_index=$(( choice - 1 ))

    if [[ " ${mine_positions[*]} " == *" $tile_index "* ]]; then
        echo -e "\e[31mkaboom, you hit a mine\e[0m"
        sleep 1
        echo -e "your new balance: \e[31m\$$player_money\e[0m"
        check_pact_loss
        echo "$player_money" > "$BALANCE_FILE"
        sleep 0.5
        read -n 1 -s -r -p "press any key to return"
        exit 0
    else
        echo -e "\e[32msafe pick\e[0m"
        sleep 1
        safe_picks=$(( safe_picks + 1 ))
        current_multiplier=$(( current_multiplier + 1 ))
    fi
done

echo -e "\e[32mcongratulations! you cleared the board\e[0m"
winnings=$(( bet * current_multiplier ))
player_money=$(( player_money + winnings ))
echo -e "your new balance: \e[32m\$$player_money\e[0m"
echo "$player_money" > "$BALANCE_FILE"
read -n 1 -s -r -p "press any key to return"

