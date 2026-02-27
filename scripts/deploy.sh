#!/bin/bash
set -e

##########################################
# Configuration (EDIT THIS SECTION ONLY)
##########################################

# Root directory for all projects
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

# Server definitions
# Format: "relative_path|jar_path|screen_name"
SERVERS=(

)

# Client definitions
# Format: "relative_path|screen_name"
CLIENTS=(
  "sawit-client|sawit-client"
)

##########################################
# Argument parsing
##########################################
JAVA_ARGS=""
RUN_SERVER=false
RUN_CLIENT=false

if [ $# -eq 0 ]; then
  echo "Usage: $0 [--prod] [--server] [--client]"
  exit 1
fi

for arg in "$@"; do
  case "$arg" in
    --prod)
      JAVA_ARGS="--spring.profiles.active=prod"
      echo "[INFO] Mode           : production"
      ;;
    --server)
      RUN_SERVER=true
      ;;
    --client)
      RUN_CLIENT=true
      ;;
    *)
      echo "[WARN] Unknown option : $arg"
      ;;
  esac
done

##########################################
# Helper functions
##########################################

stop_screen () {
  SCREEN_NAME="$1"

  if screen -list | grep -q "$SCREEN_NAME"; then
    echo "[INFO] Stopping        : $SCREEN_NAME"
    screen -S "$SCREEN_NAME" -X stuff $'\003'
    sleep 5
  fi
}

run_server () {
  REL_PATH="$1"
  JAR_PATH="$2"
  SCREEN_NAME="$3"

  APP_DIR="$ROOT_DIR/$REL_PATH"

  echo "[INFO] ----------------------------------------"
  echo "[INFO] Deploying       : $SCREEN_NAME"
  echo "[INFO] Directory       : $APP_DIR"
  echo "[INFO] Jar             : $JAR_PATH"

  cd "$APP_DIR"

  echo "[INFO] Building        : Gradle"
  ./gradlew clean build -x test

  stop_screen "$SCREEN_NAME"

  screen -dmS "$SCREEN_NAME" bash -c "
    echo '[INFO] Running        : $SCREEN_NAME'
    java -jar $APP_DIR/$JAR_PATH $JAVA_ARGS
  "

  echo "[INFO] Started         : $SCREEN_NAME"
}

run_client () {
  REL_PATH="$1"
  SCREEN_NAME="$2"

  APP_DIR="$ROOT_DIR/$REL_PATH"

  echo "[INFO] ----------------------------------------"
  echo "[INFO] Deploying       : $SCREEN_NAME"
  echo "[INFO] Directory       : $APP_DIR"

  cd "$APP_DIR"

  echo "[INFO] Installing      : npm dependencies"
  npm install --legacy-peer-deps

  echo "[INFO] Building        : Next.js"
  npm run build

  stop_screen "$SCREEN_NAME"

  screen -dmS "$SCREEN_NAME" bash -c "
    echo '[INFO] Running        : $SCREEN_NAME'
    npm run start
  "

  echo "[INFO] Started         : $SCREEN_NAME"
}

##########################################
# Execution
##########################################

if [ "$RUN_SERVER" = true ]; then
  for SERVER in "${SERVERS[@]}"; do
    IFS="|" read -r _Path JAR SCREEN <<< "$SERVER"
    run_server "$_Path" "$JAR" "$SCREEN"
  done
fi

if [ "$RUN_CLIENT" = true ]; then
  for CLIENT in "${CLIENTS[@]}"; do
    IFS="|" read -r _Path SCREEN <<< "$CLIENT"
    run_client "$_Path" "$SCREEN"
  done
fi

echo "[INFO] ----------------------------------------"
echo "[INFO] Deployment finished"
