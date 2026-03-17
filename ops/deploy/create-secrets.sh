#!/usr/bin/bash

source ../../.env.k3s

# Initial Namespaces
kubectl apply -f base/namespaces.yml

# ECR
kubectl delete secret regcred -n abrepo --ignore-not-found=true
kubectl create secret docker-registry regcred \
        -n abrepo \
        --docker-server="$AWS_ECR_ACCOUNT.dkr.ecr.$AWS_ECR_REGION.amazonaws.com" \
        --docker-username=AWS \
        --docker-password=`aws ecr get-login-password --profile $AWS_ECR_PROFILE --region $AWS_ECR_REGION` \
        --docker-email=abc@abc.com

# Rails
kubectl delete secret abrepo-rails-secrets -n abrepo --ignore-not-found=true
kubectl create secret generic abrepo-rails-secrets \
        -n abrepo \
        --from-literal=DB_USERNAME=$DB_USERNAME \
        --from-literal=DB_PASSWORD=$DB_PASSWORD \
        --from-literal=RAILS_MASTER_KEY=$RAILS_MASTER_KEY \
        --from-literal=STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY \
        --from-literal=STRIPE_WEBHOOK_SECRET_KEY=$STRIPE_WEBHOOK_SECRET_KEY \
        --from-literal=USER_IMPORTER_EMAIL=$USER_IMPORTER_EMAIL \
        --from-literal=USER_IMPORTER_PASSWORD=$USER_IMPORTER_PASSWORD\
        --from-literal=SMTP_SERVER_USERNAME=$SMTP_SERVER_USERNAME \
        --from-literal=SMTP_SERVER_PASSWORD=$SMTP_SERVER_PASSWORD \
        --from-literal=SMTP_SERVER_ADDRESS=$SMTP_SERVER_ADDRESS
