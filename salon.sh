#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n\n~~~~~ Salon Appointment Scheduler ~~~~~\n\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi

  echo -e "How may I help you?"
  echo -e "\n1) Cut\n2) color\n3) perm\n4) style\n5) trim\n6) exit"
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ [0-5] ]]
  then
  SERVICE_MENU
  fi
  
  if [[ $SERVICE_ID_SELECTED =~ 6 ]]
  then 
  EXIT
  fi

  if [[ ! $SERVICE_ID_SELECTED =~ [0-6] ]]
  then
  MAIN_MENU "Please enter a number 1-5 to select a service"
  fi
}

SERVICE_MENU(){

  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # check for customer
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
  echo -e "\nwhat's your name?"
  read CUSTOMER_NAME
  
  # insert customer
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nHello, $(echo $CUSTOMER_NAME | sed 's/^ *//'). When would you like to come in for your $(echo $SERVICE_NAME | sed 's/^ *//')?"
  read SERVICE_TIME

  # insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # success
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ *//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *//')."
}

EXIT(){
  echo -e "\nHave a good day."
}

MAIN_MENU