FROM alpine:3.9

RUN apk add --update --no-cache curl bind-tools jq dos2unix

WORKDIR /usr/src/app

ENV DDNS=$DDNS

ENV LOGIN=$LOGIN

ENV PASSWORD=$PASSWORD

COPY dynhost.sh .

RUN chmod +x ./dynhost.sh

RUN dos2unix -b ./dynhost.sh

RUN ln -sf /usr/src/app/dynhost.sh /etc/periodic/15min/dynhost

CMD ["crond", "-f"]
