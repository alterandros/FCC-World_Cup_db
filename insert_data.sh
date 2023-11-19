#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Erase all data before starting
echo $($PSQL "TRUNCATE teams, games;")

cat games.csv | while  IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  if [[ $YEAR != year ]]
  then
    # Select team_id if winner
    TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # If not found
    if [[ -z $TEAM_ID_W ]]
    then
      # Insert team
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]; 
      then
        echo Inserted winner into teams, $WINNER
      fi
      # Get new team_id
      TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Select team_id if opponent
    TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # If not found
    if [[ -z $TEAM_ID_O ]]
    then
      # Insert team
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]; 
      then
        echo Inserted opponent into teams, $OPPONENT
      fi
      # Get new team_id
      TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Fill in the games table rows
    INSERT_GAME_ROW_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
    VALUES($YEAR,'$ROUND',$TEAM_ID_W,$TEAM_ID_O,$W_GOALS,$O_GOALS)")
      if [[ $INSERT_GAME_ROW_RESULT == "INSERT 0 1" ]]; 
      then
        echo Inserted game row, $YEAR $ROUND $TEAM_ID_W $TEAM_ID_O $W_GOALS $O_GOALS
      fi
  fi
done
