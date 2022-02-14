FROM alpine:latest

RUN apk add --no-cache postfix

EXPOSE 25
COPY entrypoint.sh /
COPY main.cf /etc/postfix

ENTRYPOINT ["/entrypoint.sh"]
