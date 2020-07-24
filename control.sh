#!/bin/bash

RED='\033[0;31m'
LYELLOW='\033[0;93m'
NC='\033[0m' # No Color

PROCESS_NAME=centmonit
PID_FILE=run.pid

_dirname=$(dirname $0)
if [ "$_dirname" != "./" ] && [ "$_dirname" != "." ]; then
  printf "${LYELLOW}Go go root folder \"%s\"${NC}\n" $_dirname
  cd $_dirname
fi

# ----------------------------------
# --------  Help functions  --------
# ----------------------------------

# return 0 => it's already run, don't start process
# return 1 => not run, so you could start process
should_i_run () {
  local _allow_run=0
  if [ ! -f "$PID_FILE" ]; then
    _allow_run=1
  else
    _pid=`cat $PID_FILE`
    if [ "$_pid" -eq 0 ]; then
      _allow_run=1
    else
      _live_pid=$(pgrep $PROCESS_NAME)
      if [ -z "$_live_pid" ]; then
        _allow_run=1
      fi
    fi
  fi
  echo "$_allow_run"
}

start () {
  printf "${LYELLOW}"
  _runable=$(should_i_run)

  if [ "$_runable" -eq 0 ]; then
    printf "Already running, pls check \"run.pid\" file\n"
  else
    printf "${LYELLOW}Starting CentMonit...\n"
    nohup ./bin/centmonit >/dev/null 2>&1 & echo $! > $PID_FILE
    printf "CentMonit is now running with PID %s\n" $(cat $PID_FILE)
  fi
  printf "END!${NC}\n"
}

stop () {
  printf "${LYELLOW}"
  _runable=$(should_i_run)

  if [ "$_runable" -eq 1 ]; then
    printf "Not running\n"
  else
    printf "Shutdown CentMonit...\n"
    kill -9 $(pgrep $PROCESS_NAME)
    echo 0 > $PID_FILE

    _pid=$(pgrep $PROCESS_NAME)
    if [ -z "$_pid" ]; then
      printf "Now stopped\n"
    fi
  fi

  printf "END!${NC}\n"
}

status () {
  printf "${LYELLOW}"
  printf "Checking CentMonit...\n"

  _runable=$(should_i_run)

  if [ "$_runable" -eq 1 ]; then
    printf "Not running\n"
  else
    printf "Running with PID %s\n" $(cat $PID_FILE)
  fi

  printf "END!${NC}\n"
}

# ------------------------
# --------  Main  --------
# ------------------------

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  *)
    echo -e "${LYELLOW}"
    echo "--------------------------------------------------------"
    echo "Usage: ./control.sh <start> | <stop> | <status>"
    echo "--------------------------------------------------------"
    echo -e "${NC}"
    exit 1
    ;;
esac
exit $?
