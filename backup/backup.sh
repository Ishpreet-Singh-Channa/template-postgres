#!/bin/sh

set -e


YELLOW="\033[33m"
GRAY="\033[90m"
RED="\033[31m"
RESET="\033[0m"
GREEN="\033[32m"
CYAN="\033[36m"

printf "${GREEN}[INIT]${RESET}\t Setting up variables...\n"

# Validate BACKUP_INTERVAL
if [ -z "$BACKUP_INTERVAL" ]; then
    printf "${YELLOW}[WARN]${RESET}\t ${YELLOW}BACKUP_INTERVAL${RESET} is not set. Using default value of 1 Hour.\n"
    BACKUP_INTERVAL=3600
else
    case "$BACKUP_INTERVAL" in
        *[!0-9]*)
        printf "${RED}[ERROR]${RESET}\t ${RED}BACKUP_INTERVAL${RESET} must be a valid integer.\n"
        exit 1
        ;;
    esac
fi
printf "${GREEN}[INIT]${RESET}\t ${CYAN}BACKUP_INTERVAL${RESET} set to ${CYAN}${BACKUP_INTERVAL} seconds${RESET}.\n"

# Validate BACKUP_NUMBERS
if [ -z "$BACKUP_NUMBERS" ]; then
    printf "${YELLOW}[WARN]${RESET}\t ${YELLOW}BACKUP_NUMBERS${RESET} not set. Defaulting to 3.\n"
    BACKUP_NUMBERS=3
else
    case "$BACKUP_NUMBERS" in
        *[!0-9]*|0)
            printf "${RED}[ERROR]${RESET}\t ${RED}BACKUP_NUMBERS${RESET} must be a positive integer.\n"
            exit 1
            ;;
    esac
fi
printf "${GREEN}[INIT]${RESET}\t ${CYAN}BACKUP_NUMBERS${RESET} set to ${CYAN}${BACKUP_NUMBERS}${RESET}.\n"

# Validate PostgreSQL credentials
if [ -z "$POSTGRES_USER" ]; then
    printf "${RED}[ERROR]${RESET}\t ${RED}POSTGRES_USER${RESET} is not set.\n"
    exit 1
fi
if [ -z "$POSTGRES_PASSWORD" ]; then
    printf "${RED}[ERROR]${RESET}\t ${RED}POSTGRES_PASSWORD${RESET} is not set.\n"
    exit 1
fi

# Export password for pg_dump
export PGPASSWORD="$POSTGRES_PASSWORD"

if [ -z "$POSTGRES_DB" ]; then
    printf "${RED}[ERROR]${RESET}\t ${RED}POSTGRES_DB${RESET} is not set.\n"
    exit 1
fi
printf "${GREEN}[INIT]${RESET}\t PostgreSQL credentials present, validating...\n"

# Validate PostgreSQL connection
MAX_RETRIES=12
COUNT=0

until pg_isready -h postgres -p 5432 -U "$POSTGRES_USER" > /dev/null 2>&1; do
  if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
    printf "${RED}[ERROR]${RESET}\t PostgreSQL not ready after waiting.\n"
    exit 1
  fi

  printf "${YELLOW}[WAIT]${RESET}\t Waiting for PostgreSQL...\n"
  COUNT=$((COUNT + 1))
  sleep 5
done
printf "${GREEN}[INIT]${RESET}\t PostgreSQL is ready!\n"

# Validate AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    printf "${RED}[ERROR]${RESET}\t ${RED}AWS_ACCESS_KEY_ID${RESET} is not set.\n"
    exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    printf "${RED}[ERROR]${RESET}\t ${RED}AWS_SECRET_ACCESS_KEY${RESET} is not set.\n"
    exit 1
fi
if [ -z "$AWS_REGION" ]; then
    printf "${RED}[ERROR]${RESET}\t ${RED}AWS_REGION${RESET} is not set.\n"
    exit 1
fi
if [ -z "$AWS_S3_BUCKET" ]; then
    printf "${RED}[ERROR]${RESET}\t ${RED}AWS_S3_BUCKET${RESET} is not set.\n"
    exit 1
fi

printf "${GREEN}[INIT]${RESET}\t Starting backup loop...\n"

INDEX=1
while true; do
    TIMESTAMP=$(date +%F_%H-%M-%S)
    FILE="/backups/backup_${INDEX}.sql.gz"

    printf "${TIMESTAMP} ${CYAN}[BACKUP]${RESET}\t Creating backup slot ${INDEX}...\n"

    if ! pg_dump \
        -h postgres \
        -p 5432 \
        -U "$POSTGRES_USER" \
        --no-owner \
        --no-acl \
        "$POSTGRES_DB" | gzip > "$FILE"; then
        printf "${TIMESTAMP} ${RED}[ERROR]${RESET}\t Backup failed.\n"
        sleep "$BACKUP_INTERVAL"
        continue
    fi

    printf "${TIMESTAMP} ${CYAN}[UPLOAD]${RESET}\t Uploading slot ${INDEX} to S3...\n"

    if ! aws s3 cp "$FILE" "s3://$AWS_S3_BUCKET/backup_${INDEX}.sql.gz"; then
        printf "${TIMESTAMP} ${RED}[ERROR]${RESET}\t Upload failed.\n"
        sleep "$BACKUP_INTERVAL"
        continue
    fi

    printf "${TIMESTAMP} ${GREEN}[SUCCESS]${RESET}\t Slot ${INDEX} updated.\n"

    rm -f "$FILE"

    # Rotate index
    INDEX=$((INDEX + 1))
    if [ "$INDEX" -gt "$BACKUP_NUMBERS" ]; then
        INDEX=1
    fi

    printf "${TIMESTAMP} ${YELLOW}[WAIT]${RESET}\t Sleeping for ${BACKUP_INTERVAL} seconds...\n"
    sleep "$BACKUP_INTERVAL"
done