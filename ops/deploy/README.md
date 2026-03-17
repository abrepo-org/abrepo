# Deploy Notes

* Database is deployed via 311crimemap project
* No k3 staging
* Goal is to run this project on k3s cluster shared with other projects,
  separated by namespace.
  * Get rid of hosting on Digital Ocean, and move to larger, cheaper Hetzner box.

* `./create-secrets.sh`
* `./create-configmaps-production.sh`
* `./deploy-app.sh`

## Database Quirks

* Need to add ${DB_USER} to pgpool helm chart - this is run in
  `create-configmaps-production.sh`

```sh
helm upgrade core-db bitnami/postgresql-ha \
     -n core-db \
     --version 14.3.1 \
     --reuse-values \
     --set pgpool.useConnectionCache=true \
     --set pgpool.customUsers.usernames="$DB_USERNAME" \
     --set pgpool.customUsers.passwords="$DB_PASSWORD"
```

### Initial Database Setup

* add user privileges: replace ${DB_USER}, ${DB_PASSWORD}, ${DB_NAME}

```sql
CREATE DATABASE ${DB_NAME};

CREATE USER ${DB_USER} WITH PASSWORD ${DB_PASSWORD};
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};

\c abrepo_www_prod

GRANT ALL ON SCHEMA public TO ${DB_USER};
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${DB_USER};
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${DB_USER};
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO ${DB_USER};

-- for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ${DB_USER};
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ${DB_USER};
```


### Verifying: Port Forwarding

* Test on `localhost:8080`: `kubectl port-forward svc/abrepo-nginx-service 8080:80 -n abrepo`
* Verify host firewall isn't blocking traffic - currently only whitelists cloudflare ips.


## Cert Quirks

* Add additional zone (abrepo.com) domain to cloudflare token
* Add separate ClusterIssuer `letsencrypt-abrepo-issuer` for abrepo project
  * these are still namespaced in `cert-manager`
  * is used in `abrepo-nginx-ingress` annotations:
    `cert-manager.io/cluster-issuer: letsencrypt-abrepo-issuer`

