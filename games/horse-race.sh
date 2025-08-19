#!/bin/bash
# horse_race.sh

source /usr/lib/the-house/games/common.sh

player_money=$(<"$BALANCE_FILE")
clear

echo "welcome to horse race: pays 4x"
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

num_horses=5
track_length=20

echo
echo "horses in the race:"
for (( i=1; i<=num_horses; i++ )); do
    echo "horse #$i"
done
echo
read -r -p "pick a horse to bet on (1-$num_horses): " player_horse
if ! [[ "$player_horse" =~ ^[0-9]+$ ]] || (( player_horse < 1 || player_horse > num_horses )); then
    echo "invalid choice"
    read -n 1 -s -r -p "press any key to return"
    exit 1
fi

sleep 0.5
echo
echo "the race is starting"
sleep 0.5
echo "note: your horse is marked with the [*]"
sleep 1

positions=()
for (( i=0; i<num_horses; i++ )); do
    positions[i]=0
done

winner=0
while (( winner == 0 )); do
    clear
    echo "horse race:"
    
    for (( i=0; i<num_horses; i++ )); do
        move=$(( RANDOM % 2 ))
        positions[i]=$(( positions[i] + move ))
        if (( positions[i] >= track_length )); then
            winner=$(( i + 1 ))
        fi  

        printf "horse #%d: " $(( i + 1 ))
        for (( j=0; j<track_length; j++ )); do
    	if (( j == positions[i] )); then
           printf ">"
    	else
           printf "_"
    	fi
	done
	printf "|"
        if (( i + 1 == player_horse )); then
            printf " [*]"
        fi
        printf "\n"
    done   
    sleep 0.2
  done

echo
if (( winner == player_horse )); then
    winnings=$(( bet * 4 )) 
    player_money=$(( player_money + winnings ))
    echo -e "\e[32myour horse won\e[0m"
    sleep 1
    echo -e "your new balance: \e[32m\$$player_money\e[0m"
else
    echo -e "\e[31mhorse $winner won, you lose\e[0m"
    sleep 1
    echo -e "your new balance: \e[31m\$$player_money\e[0m"
    check_pact_loss
fi
sleep 0.5
echo "$player_money" > "$BALANCE_FILE"
read -n 1 -s -r -p "press any key to return"

