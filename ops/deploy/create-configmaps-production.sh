#!/usr/bin/bash
source ../../.env.k3s

# add db user to pgpool helm chart
helm upgrade core-db bitnami/postgresql-ha \
     -n core-db \
     --version 14.3.1 \
     --reuse-values \
     --set pgpool.useConnectionCache=true \
     --set pgpool.customUsers.usernames="$DB_USERNAME" \
     --set pgpool.customUsers.passwords="$DB_PASSWORD"

# rails app
kubectl delete configmap abrepo-rails-configmap -n abrepo --ignore-not-found=true
kubectl create configmap abrepo-rails-configmap -n abrepo \
        --from-literal=AWS_REGION=$AWS_REGION \
        --from-literal=AWS_ECR_PROFILE=$AWS_ECR_PROFILE \
        --from-literal=AWS_ECR_REGION=$AWS_ECR_REGION \
        --from-literal=AWS_ECR_ACCOUNT=$AWS_ECR_ACCOUNT \
        --from-literal=RAILS_ENV=$RAILS_ENV \
        --from-literal=PG_HOST=$PG_HOST \
        --from-literal=PG_PORT=$PG_PORT \
        --from-literal=FILE_HOST=$FILE_HOST \
        --from-literal=STRIPE_PUBLISHABLE_KEY=$STRIPE_PUBLISHABLE_KEY \
        --from-literal=STRIPE_DEFAULT_LOOKUP_KEY=$STRIPE_DEFAULT_LOOKUP_KEY \
        --from-literal=ABANNOTATE_HOSTS=$ABANNOTATE_HOSTS \
        --from-literal=MAILER_URL_HOST=$MAILER_URL_HOST \
        --from-literal=SMTP_SENDER_NAME=$SMTP_SENDER_NAME \
        --from-literal=SMTP_SENDER_EMAIL=$SMTP_SENDER_EMAIL \
        --from-literal=RAILS_LOG_TO_STDOUT=$RAILS_LOG_TO_STDOUT \
        --from-literal=OBFUSCATE_ENABLED=$OBFUSCATE_ENABLED

# nginx
kubectl apply -f production/nginx/abrepo-nginx-configmap.yml
