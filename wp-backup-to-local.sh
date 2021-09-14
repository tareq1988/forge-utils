#!/usr/bin/env bash

# input:
# - username
# - ip
# - domain

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

function red {
    printf "${RED}$@${NC}\n"
}

function green {
    printf "${GREEN}$@${NC}\n"
}

function yellow {
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
    red "Error: username is required" && exit 1
fi

if [ -z $2 ]; then
    red "Error: hostname is required" && exit 2
fi

if [ -z $3 ]; then
    red "Error: domain is required" && exit 3
fi

USERNAME=$1
HOST=$2
DOMAIN=$3
DATABASE="database.sql.gz"
HOSTNAME="$USERNAME@$HOST"

# Steps
# 1. SSH into server
# 2. "cd" into the "$domain" folder
# 3. Run "wp db export"

yellow "(1/3) Exporting database..."
ssh $HOSTNAME /bin/bash <<EOT
    cd $DOMAIN;

    if [ -f "$DATABASE" ] ; then
        echo "Found $DATABASE, deleting"
        rm "$DATABASE"
    fi

    wp db export - --path=./public/ | gzip > $DATABASE
EOT

# Local
# 1. Create a folder with "$domain"
# 2. Run rsync and download everything to local
# 3. Delete "database.sql.gz" from remote

if [ ! -d "$DOMAIN" ]; then
    mkdir "$DOMAIN"
fi

yellow "(2/3) Copying files..."
rsync -azh -P --exclude "wp-admin" --exclude "wp-includes" --exclude '*.log*' "$HOSTNAME:~/$DOMAIN/" "./$DOMAIN"

yellow "(3/3) Deleting remote database backup"
ssh $HOSTNAME "rm ~/$DOMAIN/$DATABASE"

green "Backup successful of $DOMAIN"
