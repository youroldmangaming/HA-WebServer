docker service create --name haproxy-service \
  --publish 8080:81 \
  --mount type=bind,source=$(pwd)/haproxy.cfg,target=/usr/local/etc/haproxy/haproxy.cfg \
  --mount type=bind,source=$(pwd)/htpasswd,target=/etc/haproxy/htpasswd \
  haproxy:latest
