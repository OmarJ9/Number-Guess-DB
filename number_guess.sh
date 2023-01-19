#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1001 ))
echo "Enter your username:"
read USERNAME

PLAY_GAME(){
  
  TRIES=0
  echo -e "\nGuess the secret number between 1 and 1000:"
  while read GUESS
  do    
      if [[ $GUESS =~ ^[0-9]+$ ]]
      then
            if [[ $GUESS -lt $NUMBER ]]
            then
                  echo "It's lower than that, guess again:"
                  TRIES=$(($TRIES+1))

            elif [[ $GUESS -gt $NUMBER ]]
            then  
                  echo "It's higher than that, guess again:"
                  TRIES=$(($TRIES+1))
            else  
                  TRIES=$(($TRIES+1))      
                  echo -e "\nYou guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
                  USER_ID=$($PSQL "SELECT u_id FROM users WHERE name = '$USERNAME'")
                  $PSQL "INSERT INTO games(guesses,u_id) VALUES ($TRIES,$USER_ID)"
                  break;
            fi
      else
            echo "That is not an integer, guess again:"
            TRIES=$(($TRIES+1))
      fi


  done
}

QUERY_RESULT=$($PSQL "SELECT * FROM users INNER JOIN games USING(u_id) WHERE name = '$USERNAME'")
if [[ -z $QUERY_RESULT ]]
then  
      $PSQL "INSERT INTO users(name) VALUES ('$USERNAME')"
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      PLAY_GAME
else
      USER_ID=$($PSQL "SELECT u_id FROM users WHERE name = '$USERNAME'")
      GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE u_id = $USER_ID")
      BEST_SCORE=$($PSQL "SELECT guesses FROM games WHERE u_id = $USER_ID ORDER BY guesses LIMIT 1")
      
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
      PLAY_GAME
      
fi
