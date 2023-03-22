FROM alpine:3.16.2

RUN sed -i 's/https/http/g' /etc/apk/repositories

RUN apk add -q ansible ansible-lint
