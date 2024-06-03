#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

WELCOME_USER() {
  echo "Enter your username:"
  read USERNAME
  
  FIND_PLAYER=$($PSQL "SELECT player_id FROM player WHERE username='$USERNAME';")
  #if not found
  if [[ ! -z $FIND_PLAYER ]]
  then
    GAMES_PLAYED=$($PSQL "SELECT COUNT(username) FROM player WHERE username='$USERNAME';")
	  BEST_GAME=$($PSQL "SELECT MIN(attempt_total) FROM player WHERE username='$USERNAME';")
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  else
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi
}

GAME() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  read guess

  if [[ ! $guess =~ ^[0-9]+$ ]]; then
    echo -e "That is not an integer, guess again:\n"
    ATTEMPT=$(($ATTEMPT + 1))
    GAME

  elif [[ $guess -gt $random_number ]]; then
    echo -e "It's lower than that, guess again:\n"
    ATTEMPT=$(($ATTEMPT + 1))
    GAME

  elif [[ $guess -lt $random_number ]]; then
    echo -e "It's higher than that, guess again:\n"
    ATTEMPT=$(($ATTEMPT + 1))
    GAME

  else [[ $guess -eq $random_number ]]
    ATTEMPT=$(($ATTEMPT + 1))
    INSERT_PLAYER=$($PSQL "INSERT INTO player(username, attempt_total) VALUES('$USERNAME', $ATTEMPT)")
    echo "You guessed it in $ATTEMPT tries. The secret number was $random_number. Nice job!"

  fi
}

RUN_GAME() {
  WELCOME_USER
  echo -e "\nGuess the secret number between 1 and 1000:\n"
  
  random_number=$((1 + RANDOM % 1000))
  ATTEMPT=0
  GAME
}

RUN_GAME
