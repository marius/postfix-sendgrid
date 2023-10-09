#!/bin/sh

if [ -n "$APIKEY" ]; then
  sed -i "s/apikey:.*/apikey:$APIKEY/" /etc/postfix/main.cf
elif [ -s "$APIKEY_FILE" ]; then
  sed -i "s/apikey:.*/apikey:`cat $APIKEY_FILE`/" /etc/postfix/main.cf
else
  echo Please specify APIKEY or provide a file via APIKEY_FILE >&2
  exit 1
fi

exec postfix start-fg
