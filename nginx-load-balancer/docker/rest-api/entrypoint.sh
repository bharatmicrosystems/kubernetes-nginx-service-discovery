#!/bin/bash

function shutdown() {
  kill -s SIGTERM $PID
  wait $PID
}

python server.py &
PID=$!

trap shutdown SIGTERM SIGINT
wait $PID

