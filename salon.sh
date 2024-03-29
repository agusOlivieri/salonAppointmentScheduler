#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\n~~~ Welcome to my salon. Please, choose a service: ~~~\n"
  SERVICES_AVAILABLES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES_AVAILABLES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a number."
  else
    SERVICE_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_SELECTED ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      HANDLE_SERVICE $SERVICE_SELECTED
    fi
  fi
}

HANDLE_SERVICE() {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if not found
  if [[ -z $PHONE ]]
  then
    # ask name
    echo -e "\nI don't have a record of your phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer into database
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # get customer info
  NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  NAME_FORMATTED=$(echo $NAME | sed -E 's/\s//g')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$NAME_FORMATTED'")
  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM SERVICES WHERE service_id=$1")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/\s//g')
  # ask time to appoint
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $NAME_FORMATTED?"
  read SERVICE_TIME
  # create appointment
  CREATE_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  # send to main menu
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $NAME_FORMATTED.\n"
}

MAIN_MENU
