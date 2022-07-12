FROM alpine:3.9

RUN apk add --update --no-cache curl bind-tools jq dos2unix

WORKDIR /usr/src/app

COPY dynhost.sh .
COPY DDNS.json .

RUN chmod +x ./dynhost.sh

RUN dos2unix -b ./dynhost.sh

RUN ln -sf /usr/src/app/dynhost.sh /etc/periodic/15min/dynhost

CMD ["crond", "-f"]
