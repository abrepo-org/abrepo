# ABRepo

Rails based frontend for abrepo web app

[![Rails CI/CD](https://github.com/abrepo-org/abrepo/actions/workflows/ci.yml/badge.svg)](https://github.com/abrepo-org/abrepo/actions/workflows/ci.yml)

## Branches

0. `master`: general live

1. `feature-flag/maintenance-mode`: toggle when needed

   * Still **requires database**: we toggle this branch on a new staging cluster
   * Deploy: deploy staging to same region; make sure terraform
     (tfvars) + ansible (./docker_ansible.sh) use same `region`,
     `deploy_env` and `env_id` as production
   * Point Digital Ocean IP to maintenance mode cluster (don't want dns delay with cloudflare)
   * Do maintenance, tear down, etc. Redeploy prod cluster.
   * Toggle ip back to updated prod cluster.

2. `feature-flag/landing-page-only`: will eventually be deprecated once 'live'


## Quickstart Initial Dev Setup

0. Populate environmental variables - use `*.stub` for reference
   * `.env.dev`
   * `.env.db`

1. Database locally mapped to `db/postgres`. Bitnami postgres image, requires
chown user directory 1001:1001.

`sudo chown -R 1001:1001 /db`

2. build web container: install gems and webpacker

`docker-compose build web`

3. Initialize db

Jump into container: `docker compose run web bash`


```
RAILS_ENV=development rake db:setup

# for importer user
rake db:seed
```

Now `docker-compose up` should work


## Deploy

Packer, Terraform, Ansible for Docker Swarm creation handled in
[`abrepo-ops`](https://github.com/abrepo-org/abrepo_ops)


---

## Project Docs

* [Docker Notes](./docs/docker.md)
* [Architecture and Ports](./docs/infra_arch.md)
* [Stripe](./docs/stripe.md)

#### Rails

* [Authorization](./docs/rails_authorization.md)
* [Caching](./docs/rails_caching.md)
* [Search via `pg_search`](./docs/rails_pgsearch.md)
* [Tags and taggable](./docs/rails_taggable.md)
* [Rails Assets](./docs/rails_assets.md)
* [Transactional Email](./docs/transactional_email.md)
* [Importer User](./docs/rails_importer.md)
* [Testing](./docs/rails_testing.md)

##### Rails Devise:

* [Devise Pages custom styling](./docs/devise_style.md)
* [Devise Users - Stripe](./docs/devise_stripe.md)
