#!/bin/bash

MAIN_IP="10.10.1.197"  
BACKUP_IP="10.10.2.71"  
PORT=80  
CHECK_INTERVAL=30  


check_port() {
  local ip="$1"
  nc -z -w5 "$ip" "$PORT"
  return $?
}


while true; do
  if check_port "$MAIN_IP"; then
    echo "Port $PORT is open on main instance ($MAIN_IP). Running --main command..."
    failover --main
  else
    echo "Port $PORT is not open on main instance ($MAIN_IP). Checking backup..."
    if check_port "$BACKUP_IP"; then
      echo "Port $PORT is open on backup instance ($BACKUP_IP). Running --fallback command..."
      failover --fallback
    else
      echo "Port $PORT is not open on backup instance ($BACKUP_IP). No action taken."
    fi
  fi

  sleep "$CHECK_INTERVAL"
done
