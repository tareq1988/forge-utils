#!/usr/bin/env bash

# input:
# - username
# - ip
# - domain

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

function error {
    printf "${RED}$@${NC}\n"
}

function success {
    printf "${GREEN}$@${NC}\n"
}

function warning {
    printf "${YELLOW}$@${NC}\n"
}

function usage() {
    echo "Backup WordPress from Forge to local."
    echo ""
    echo "Usage:"

    echo -e "\t<username> <host> <domain>"
    echo ""

    echo "Example:"
    echo -e "\tforge 127.128.173.182 example.com"
    echo ""
}

if [ -z $1 ]; then
    error "Error: username is required" && exit 1
fi

if [ -z $2 ]; then
    error "Error: hostname is required" && exit 2
fi

if [ -z $3 ]; then
    error "Error: domain is required" && exit 3
fi

USERNAME=$1
HOST=$2
DOMAIN=$3
DATABASE="database.sql.gz"
HOSTNAME="$USERNAME@$HOST"

# Steps
# 1. Make sure the local folder exists
# 2. Rsync the folder to remote, exclude "wp-config.php"
# 3. Unzip the database and import

if [ ! -d "$DOMAIN" ]; then
    error "Folder not found. Make sure you are running from the parent folder of the backup."
    exit 1
fi

echo "$DOMAIN/$DATABASE"

if [ ! -f "$DOMAIN/$DATABASE" ]; then
    error "Database backup not found. Exiting..."
    exit 1
fi

# Local
# 1. Create a folder with "$domain"
# 2. Run rsync and download everything to local
# 3. Delete "database.sql.gz" from remote

warning "(1/3) Copying files (wp-content)..."
rsync -azh -P $DOMAIN/public/wp-content/* "$HOSTNAME:~/$DOMAIN/public/wp-content/"

warning "(2/3) Copying database..."
rsync -azh -P $DOMAIN/$DATABASE "$HOSTNAME:~/$DOMAIN/"

warning "(3/3) Importing database..."
ssh $HOSTNAME /bin/bash <<EOT
    cd $DOMAIN;

    if [ -f "database.sql" ] ; then
        echo "Found database.sql, deleting"
        rm "database.sql"
    fi

    gzip -d $DATABASE

    wp db import database.sql --path=./public/

    echo "Deleting database.sql"
    rm database.sql
EOT

success "Restore successfull!"
