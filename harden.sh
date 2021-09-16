#!/usr/bin/env bash

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
HOSTNAME="$USERNAME@$HOST"

ssh $HOSTNAME /bin/bash <<EOT
    cd $DOMAIN/public;

    if [ -f "wp-config.php" ] ; then
        echo "Moving wp-config.php to upper dir"
        mv wp-config.php ../
    fi

    wp config set WP_DEBUG false --raw
    wp config set WP_DEBUG_DISPLAY false --raw
    wp config set WP_DEBUG_LOG false --raw
    wp config set DISALLOW_FILE_EDIT false --raw
    wp config set WP_SITEURL 'https://$DOMAIN'
    wp config set WP_HOME 'https://$DOMAIN'

EOT
