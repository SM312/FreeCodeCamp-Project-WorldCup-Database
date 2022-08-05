#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  if [[ $WINNER != 'winner' ]]
  then
    # get team_id
    TEAM_ID1=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    TEAM_ID2=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # if TEAM_ID1 not found
    if [[ -z $TEAM_ID1 ]]
    then
      # insert team
      INSERT_TEAM_RESULT1=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT1 == "INSERT 0 1" ]]
      then
        echo INSERTED into teams, $WINNER
      fi
    fi

    # if TEAM_ID2 not found
    if [[ -z $TEAM_ID2 ]]
    then
      # insert team
      INSERT_TEAM_RESULT2=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT2 == "INSERT 0 1" ]]
      then
        echo INSERTED into teams, $OPPONENT
      fi
    fi
  fi

done


cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # get game_id (USING BOTH WINNER AND OPPONENT ID TO FIND A UNIQUE GAME_ID)
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID AND round='$ROUND' AND year='$YEAR'")

    # if not found
    if [[ -z $GAME_ID ]]
    then
      # INSERT THE VALUES FOR THE NEW GAME
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES('$YEAR','$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")

      if [[ $INSERT_GAME_RESULT="INSERT 0 1" ]]
      then
        echo "INSERTED into games, $YEAR-$ROUND: $WINNER $WINNER_GOALS:$OPPONENT_GOALS $OPPONENT"
      fi
    fi
  fi

done