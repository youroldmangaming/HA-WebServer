docker service create --name nginx-service --replicas 5 --publish 81:80 \
  --mount type=bind,source=$(pwd)/html,target=/usr/share/nginx/html \
  nginx
