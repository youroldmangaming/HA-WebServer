
# HA-WebServer
Create a High Availability Web Service

## HAProxy and NGINX Setup with Basic Authentication

This document outlines the setup of an HAProxy service that acts as a reverse proxy for multiple NGINX instances, with basic authentication enabled.

### Prerequisites

- Docker installed on your server.
- Docker Swarm is initiated and each target node (in my instance there are five nodes) within the cluster has joined 
- Basic knowledge of Docker commands and configuration files.
- KeepAlived is set up across the cluster.

## Step 1: Create HAProxy Service

Run createCredentials.sh from the repository, the output with be the htpasswd file to be included in the following commands.


To create the HAProxy service, run the following Docker command:

```bash
docker service create --name haproxy-service \
  --publish 8080:81 \
  --mount type=bind,source=$(pwd)/haproxy.cfg,target=/usr/local/etc/haproxy/haproxy.cfg \
  --mount type=bind,source=$(pwd)/htpasswd,target=/etc/haproxy/htpasswd \
  haproxy:latest
```

#### Explanation:
- `--name haproxy-service`: Names the service `haproxy-service`.
- `--publish 8080:81`: Maps port 8080 on the host to port 81 on the container.
- `--mount`: Binds the local configuration files (`haproxy.cfg` and `htpasswd`) to the appropriate locations in the container.

## Step 2: Create NGINX Service

Next, create the NGINX service with the following command:

```bash
docker service create --name nginx-service --replicas 5 --publish 81:80 nginx
```

#### Explanation:
- `--name nginx-service`: Names the service `nginx-service`.
- `--replicas 5`: Creates 5 replicas of the NGINX service for load balancing.
- `--publish 81:80`: Maps port 81 on the host to port 80 on the container.

## Step 3: Configure HAProxy

Create a configuration file named `haproxy.cfg` with the following content:

```haproxy
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5000
    timeout client 50000
    timeout server 50000

frontend http_front
    bind :81
    default_backend http_back
    acl auth_ok http_auth(users)
    http-request auth unless auth_ok

backend http_back
    balance roundrobin
    server rpi14 192.168.188.141:81 check
    server rpi51 192.168.188.151:81 check
    server rpi52 192.168.188.152:81 check
    server rpi53 192.168.188.153:81 check
    server rpi54 192.168.188.154:81 check

userlist users
    user youruser password $2y$ # Ensure this hash matches the password
```
