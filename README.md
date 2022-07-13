# ovh-dynhost
Docker image to update OVH dynhosts regularly. Based on Alpine linux.

### Why
A DynHost is used to assign a dynamic ip to a subdomain.
This can be very useful to make your local development machine available via a public subdomain.

### Configure OVH
In your OVH domain settings head over to the `DynHost` tab and follow the steps to create your dynhost.

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

Of course you need to insert your credentials.

This will update the dynhost every 15 minutes if the ip changed.
