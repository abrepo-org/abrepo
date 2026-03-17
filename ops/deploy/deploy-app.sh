#!/usr/bin/bash
export GIT_COMMIT=$(git log -1 --format=%h)
export $(grep -E '^(CERT_MANAGER_EMAIL)' ../../.env.k3s)
export $(grep -E '^(AWS_ECR_(ACCOUNT|REGION))' ../../.env.k3s | xargs)
export IMAGE_REPO="$AWS_ECR_ACCOUNT.dkr.ecr.$AWS_ECR_REGION.amazonaws.com"

envsubst '${IMAGE_REPO} ${GIT_COMMIT}' < base/rails/abrepo-rails-deployment.yml | kubectl apply -f -
envsubst '${IMAGE_REPO} ${GIT_COMMIT}' < base/nginx/abrepo-nginx-deployment.yml | kubectl apply -f -

kubectl apply -f base/rails/abrepo-rails-service.yml
kubectl apply -f base/nginx/abrepo-nginx-service.yml

# Cert manager - avoid running repeatedly
# envsubst '${CERT_MANAGER_EMAIL}' < production/cert-manager-issuer.yml | kubectl apply -f -

kubectl apply -f production/nginx/abrepo-nginx-ingress.yml
