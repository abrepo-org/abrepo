#!/usr/bin/env bash
DEPLOY_ENV=$1

if [ -z ${DEPLOY_ENV} ]; then
    echo "required deploy environment: [staging | production]"
    echo "e.g. './build.sh staging'"
    exit 1;
fi

if [ -f .env ]; then
    source .env
fi

AWS_ECR_PROFILE=$AWS_ECR_PROFILE
AWS_ECR_REGION=$AWS_ECR_REGION
AWS_ECR_ACCOUNT=$AWS_ECR_ACCOUNT
WEB_IMAGE=$AWS_ECR_ACCOUNT.dkr.ecr.$AWS_ECR_REGION.amazonaws.com/abrepo/abrepo
NGINX_IMAGE=$AWS_ECR_ACCOUNT.dkr.ecr.$AWS_ECR_REGION.amazonaws.com/abrepo/abnginx


#
# DOCKER BUILD
# build from app's local Dockerfile
#

#
# tag docker images with git commit
# currently skip checkout to avoid unnecessary detatched state
# just use HEAD as tag.
# But this May change on CI/CD server
GIT_COMMIT=$(git log -1 --format=%h)
GIT_COMMIT=$GIT_COMMIT \
docker compose --env-file=.env build

# tag
echo "tagging $WEB_IMAGE:$GIT_COMMIT"
docker tag abrepo/abrepo:$GIT_COMMIT $WEB_IMAGE:$GIT_COMMIT

echo "tagging $NGINX_IMAGE:$GIT_COMMIT"
docker tag abrepo/abnginx:$GIT_COMMIT $NGINX_IMAGE:$GIT_COMMIT

# ecr creds
aws ecr get-login-password --region $AWS_ECR_REGION --profile $AWS_ECR_PROFILE | \
    docker login --password-stdin \
           --username AWS $AWS_ECR_ACCOUNT.dkr.ecr.$AWS_ECR_REGION.amazonaws.com

GIT_COMMIT=$GIT_COMMIT \
WEB_IMAGE=$WEB_IMAGE \
NGINX_IMAGE=$NGINX_IMAGE \
docker compose --env-file=.env push

#build step
echo "";
echo "building artifacts"
echo "";

#
# Mark Deploy Environment
#

# remove previous mark
if [ -f $DEFAULT_DIR/.production ] ; then
    rm "$DEFAULT_DIR/.production"
fi

if [ -f $DEFAULT_DIR/.staging ] ; then
    rm "$DEFAULT_DIR/.staging"
fi

touch "$DEFAULT_DIR/.$DEPLOY_ENV"
