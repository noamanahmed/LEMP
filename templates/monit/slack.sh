#!/bin/bash

# Slack webhook URL was never setup
if [ ! -f "/opt/slack_webhook_url" ]
then      
  exit 
fi


URL=$(cat /opt/slack_webhook_url)

if [ -z "$URL" ]
then    
    exit
fi

COLOR=${MONIT_COLOR:-$([[ $MONIT_EVENT == *"succeeded"* ]] && echo good || echo danger)}
TEXT=$(echo -e "$MONIT_EVENT: $MONIT_DESCRIPTION" | python3 -c "import json,sys;print(json.dumps(sys.stdin.read()))")

PAYLOAD="{
  \"attachments\": [
    {
      \"text\": $TEXT,
      \"color\": \"$COLOR\",
      \"mrkdwn_in\": [\"text\"],
      \"fields\": [
        { \"title\": \"Date\", \"value\": \"$MONIT_DATE\", \"short\": true },
        { \"title\": \"Host\", \"value\": \"$MONIT_HOST\", \"short\": true }
      ]
    }
  ]
}"

curl -s -X POST --data-urlencode "payload=$PAYLOAD" $URL
