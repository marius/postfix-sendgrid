# Postfix to sendgrid mail relay

[![Docker](https://github.com/marius/postfix-sendgrid/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/marius/postfix-sendgrid/actions/workflows/docker-publish.yml)

Very simple mail relay, just set the APIKEY environment variable and you should
be good to go.

This Docker image automatically updates whenever there is an update to the
underlying Alpine image and/or Postfix is updated in the Alpine package repository.
(See https://github.com/marius/postfix-sendgrid/actions for how this is implemented)

Heavily inspired by alterrebe/docker-mail-relay and simenduev/postfix-relay.

> [!WARNING]
> This assumes the host is running behind a firewall, you probably don't
> want to run this container exposed to the internet.

## Docker run

```
docker run -d -e APIKEY=YOUR_KEY -p 25:25 ghcr.io/marius/postfix-sendgrid
```

## Docker compose

```
  mailrelay:
    image: ghcr.io/marius/postfix-sendgrid
    environment:
      APIKEY: YOUR_KEY
    ports:
      - "25:25"
```

Using a secret:

```
secrets:
  sendgrid_apikey:
    file: /tank/docker/secrets/sendgrid_apikey

services:
  mailrelay:
    image: ghcr.io/marius/postfix-sendgrid
    environment:
      APIKEY_FILE: /run/secrets/sendgrid_apikey
    ports:
      - "25:25"
    secrets:
      - sendgrid_apikey
```

## Testing

On the host:

```
ruby -r net/smtp -e 'Net::SMTP.start("localhost") { |s| s.send_mail "From: from@example.com\r\n\r\nHello via sendgrid", "from@example.com", "you@example.com" }'
```

From another container:

```
host# docker run -it --rm --add-host host.docker.internal:host-gateway ubuntu
container# apt update && apt install ruby -y
container# ruby -r net/smtp -e 'Net::SMTP.start("host.docker.internal") { |s| s.send_mail "From: from@example.com\r\n\r\nHello via sendgrid", "from@example.com", "you@example.com" }'
```

## Sending email from other containers

### Example Watchtower docker compose config

```
  watchtower:
    image: containrrr/watchtower
    environment:
      WATCHTOWER_NOTIFICATIONS: email
      WATCHTOWER_NOTIFICATION_EMAIL_TO: you@example.com
      WATCHTOWER_NOTIFICATION_EMAIL_FROM: watchtower@example.com
      WATCHTOWER_NOTIFICATION_EMAIL_SERVER: host.docker.internal
      WATCHTOWER_NOTIFICATION_EMAIL_SERVER_TLS_SKIP_VERIFY: "true"
      WATCHTOWER_NOTIFICATION_EMAIL_DELAY: 120
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    extra_hosts:
      - host.docker.internal:host-gateway
```

The delay is important, otherwise Watchtower might not be able to send emails.
