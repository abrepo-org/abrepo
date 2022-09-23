#!/usr/bin/env bash
#
#dev runner; execute app, bash, etc. in docker context.
#

#if # args greater than 0, set DEFAULT_CMD to input values
if [ $# -gt "0" ]; then
    DEFAULT_CMD=$1
fi

# sudo docker run \
#      --user $(id -u):$(id -g) \
#      --mount type=bind,source="$(pwd)"/app,target=/app \
#      --env-file .env \
#      -it 424385760710.dkr.ecr.us-east-2.amazonaws.com/vergeman/abrepo:latest \
#      $DEFAULT_CMD

sudo chown -R $USER:$USER .
sudo chown 1001:1001 -R db #bitnami image
#sudo docker-compose run web $DEFAULT_CMD
docker exec -it abrepo_web_1 $DEFAULT_CMD
