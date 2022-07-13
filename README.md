# ovh-dynhosts
Docker image to update OVH dynhosts regularly. Based on Alpine linux.

## [Small domain lists](#small-domain-lists)

## [Large domain lists](#large-domain-lists)

### Why
A DynHost is used to assign a dynamic ip to a subdomain.
This can be very useful to make your local development machine available via a public subdomain.

### Configure OVH
In your OVH domain settings head over to the `DynHost` tab and follow the steps to create your dynhost.

## Small domain lists

### Run container
The image is available via Docker Hub.

```
docker run \
  -e DDNS=domain.example.com,subdomain.example.com,otherdomain.com \
  -e LOGIN=login \
  -e PASSWORD=password \
  --restart always \
  --name ovh-dynhosts \
  paulobergine/ovh-dynhosts
```

**Or via docker-compose:**

```yml
version: '3'

services:
  ovh-dynhosts:
    image: paulobergine/ovh-dynhosts:latest
    container_name: ovh-dynhosts
    restart: unless-stopped
    environment:
      DDNS: domain.example.com,subdomain.example.com,otherdomain.com
      LOGIN: login
      PASSWORD: password
```

Of course you need to insert your credentials.

This will update the dynhost every 15 minutes if the ip changed.

## Large domain lists

If you need to update a large list of domains, you can use a JSON file instead of an environment variable.

Use this Dockerfile : 

```
FROM alpine:3.9

RUN apk add --update --no-cache curl bind-tools jq dos2unix

WORKDIR /usr/src/app

COPY dynhost.sh .
COPY DDNS.json .

RUN chmod +x ./dynhost.sh

RUN dos2unix -b ./dynhost.sh

RUN ln -sf /usr/src/app/dynhost.sh /etc/periodic/15min/dynhost

CMD ["crond", "-f"]
```

**Or via docker-compose:**

```yml
version: '3'

services:
  ovh-dynhosts:
    container_name: ovh-dynhosts
    restart: unless-stopped
    build:
      dockerfile: Dockerfile
      context: .
      args:
        LOGIN: "login"
        PASSWORD: "password"
```

For this to work you will need to create and add to the folder a JSON file like this example :

```json
{
    "DDN": "domain.example.com"
}
{
    "DDN": "subdomain.example.com"
}
{
    "DDN": "otherdomain.com."
}
```

Then add the new script : 

```sh
#!/bin/sh

echo "Starting script"

DDNS=`cat /usr/src/app/DDNS.json | jq '.DDN'`

for DDN in $DDNS
do
  echo "Checking IP" >> /usr/src/app/dynhost.log

  IP=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d \")
  CURRENT_IP=$(dig +short $DDN)

  if [ "$IP" ]; then
    if [ "$CURRENT_IP" != "$IP" ]; then
        echo "Updating $DDN from $CURRENT_IP to $IP" >> dynhost.log
        curl --user "${LOGIN}:${PASSWORD}" "http://www.ovh.com/nic/update?system=dyndns&hostname=${DDN}&myip=${IP}" >> dynhost.log 2>&1
    else
        echo "No update required" >> dynhost.log
    fi
  else
    echo "IP not found" >> dynhost.log
  fi
done
```
