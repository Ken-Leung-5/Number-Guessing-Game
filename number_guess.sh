#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESS_ROUND(){
USER_GUESS=$1
while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
do 
  echo -e "\nThat is not an integer, guess again:"
  read USER_GUESS
done

if [[ $USER_GUESS > $SECRET_NUMBER ]]
then
  echo -e "\nIt's lower than that, guess again:"
elif [[ $USER_GUESS < $SECRET_NUMBER ]]
then
  echo -e "\nIt's higher than that, guess again:"
fi
}  

# reset game variable
LOWER_LIMIT=0
UPPER_LIMIT=1000
GAMES_PLAYED=0
NUMBER_OF_GUESS=0
# generate a number between 1 to 1000, only 998 possible number, which is 1 ,2,...,999
SECRET_NUMBER=$((RANDOM % 998 + 2 + $LOWER_LIMIT))
# echo secret number is $SECRET_NUMBER

# display title
echo -e "\n~~~ Number Guessing Game ~~~\n"
# ask for username
echo "Enter your username:"
read USERNAME

# check user-info from database
USER_INFO=$($PSQL "SELECT games_played, best_game FROM records WHERE username='$USERNAME';")
if [[ -z $USER_INFO ]]
then
  # if username not found, print welcome message for new user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # if username found, print welcome message for user
  read GAMES_PLAYED BEST_GAME < <(IFS='|'; echo $USER_INFO)
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# start guessing
echo -e "\nGuess the secret number between 1 and 1000:"
# repeat guessing until USER_GUESS = SECRET_NUMBER
while [[ $USER_GUESS != $SECRET_NUMBER ]]
do
  read USER_GUESS
  ((NUMBER_OF_GUESS += 1))
  GUESS_ROUND $USER_GUESS
done
((GAMES_PLAYED += 1))


if [[ -z $USER_INFO ]]
then
  # insert into records for new user
  GAME_RESULT=$($PSQL "INSERT INTO records(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESS);")
else
  # update records for orginal user
  GAME_RESULT=$($PSQL "UPDATE records SET games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
  if [[ $NUMBER_OF_GUESS < $BEST_GAME ]]
  then
    # update best_game
    GAME_RESULT=$($PSQL "UPDATE records SET best_game=$NUMBER_OF_GUESS WHERE username='$USERNAME';")
  fi
fi

echo -e "\nYou guessed it in $NUMBER_OF_GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"