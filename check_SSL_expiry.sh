#!/bin/bash

send_slack_notification() {
    local webhook_url="$1"
    local message="$2"
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$webhook_url"
}

get_ssl_expiry_date() {
    local domain="$1"
    echo | openssl s_client -servername "$domain" -connect "$domain":443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut -d= -f2
}

send_slack_notiication "$SLACK_WEBHOOK_URL" "Aug 21 - Task-1"

while read -r domain; do
    expiry_date=$(get_ssl_expiry_date "$domain")
    expiry_date_seconds=$(date -d"$expiry_date" +%s)
    current_date_seconds=$(date +%s)
    remaining_days=$(( (expiry_date_seconds - current_date_seconds) / 86400 ))
    message="SSL Expiry Alert\n* Domain : $domain\n* Warning : The SSL certificate for $domain will expire in $remaining_days days."
    echo $message
    send_slack_notification "$SLACK_WEBHOOK_URL" "$message"
done < domains.txt
