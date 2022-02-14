#!/bin/sh

sed -i "s/apikey:.*/apikey:$APIKEY/" /etc/postfix/main.cf

exec postfix start-fg
