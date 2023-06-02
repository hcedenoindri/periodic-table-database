#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

GET_ELEMENT() {
  if [[ $1 =~ [0-9] && ! $1 =~ [a-z] && ! $1 =~ [A-Z] ]]
  then
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number='$1'")
    if [[ ! -z $ELEMENT ]]
    then
      echo $ELEMENT
      return
    fi
  fi

  ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol='$1'")
  if [[ ! -z $ELEMENT ]]
  then
    echo $ELEMENT
    return
  fi

  ELEMENT=$($PSQL "SELECT * FROM elements WHERE name='$1'")
  if [[ ! -z $ELEMENT ]]
  then
    echo $ELEMENT
    return
  fi
}

GET_PROPERTIES() {
  PROPERTIES=$($PSQL "SELECT * FROM properties WHERE atomic_number=$1")
  echo $PROPERTIES
}

GET_TYPE() {
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id=$1")
  echo $TYPE
}

MAIN() {
  if [[ -z $1 ]]
  then
    echo -e "Please provide an element as an argument."
    exit
  fi
  
  # get element (atomic number, symbol, name)
  ELEMENT=$(GET_ELEMENT $1)
  if [[ -z $ELEMENT ]]
  then
    echo -e "I could not find that element in the database."
    exit
  fi
  # parse atomic number, symbol, name
  ATOMIC_NUMBER=$(echo $ELEMENT | sed -r "s/\|.*//")
  SYMBOL=$(echo $ELEMENT | sed -r "s/[0-9]+\|//" | sed -r "s/\|[a-z]+//i")
  NAME=$(echo $ELEMENT | sed -r "s/.*\|//")

  # get properties
  PROPERTIES=$(GET_PROPERTIES $ATOMIC_NUMBER)
  PARSED_PROPS=$(echo $PROPERTIES | sed -r "s/\|/ m: /" | sed -r "s/\|/ mp: /" | sed -r "s/\|/ bp: /" | sed -r "s/\|.*//")
  # parse properties
  TYPE_ID=$(echo $PROPERTIES | sed -r "s/.*\|//")
  MASS=$(echo $PARSED_PROPS | sed -r "s/.*m: ([0-9]+\.*[0-9]+).*/\1/")
  # melting point
  MP=$(echo $PARSED_PROPS | sed -r "s/.*mp: (-*[0-9]+\.*[0-9]+).*/\1/")
  # boiling point
  BP=$(echo $PARSED_PROPS | sed -r "s/.*bp: (-*[0-9]+\.*[0-9]+).*/\1/")

  # get type
  TYPE=$(GET_TYPE $TYPE_ID)

  echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
}

MAIN $1
