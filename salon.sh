#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Shop ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  echo "Which services would you like?"
  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
}

SERVICE_MENU() {
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if not found then add customer
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    # insert into db
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # ask for service time
  echo -e "\nPlease enter a time:"
  read SERVICE_TIME
  # Add too appointment table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_INFO_FORMATTED=$(echo $SERVICE_INFO | sed 's/ |/"/')
  echo -e "I have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
}


MAIN_MENU

case $SERVICE_ID_SELECTED in
  1 | 2 | 3) SERVICE_MENU $SERVICE_ID_SELECTED;;
  *) MAIN_MENU "Please enter a valid service option." ;;
esac
