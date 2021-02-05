# Stripe Notes

## Install

1. Create an account on Stripe
2. Install 'gem stripe'
3. Set stripe keys: `PUBLISHABLE_KEY, SECRET_KEY, WEBHOOK_KEY`
    * need to create a webhook (externally accessible route) to generate a key.
    * webhooks are locally accessible/tested via the stripe CLI.

Stripe accounts have their own test/prod environments and
keys. Accounts are toggled to "test" by default, and need to manually
be toggled to live.


## Stripe CLI

Used to test a webhook locally; installed in the `Dockerfile` via
apt-get.

You will need to re-authenticate on every `docker-compose` session -
auth will persist only during lifetime of a running container.

To run the stripe cli, run `./docker_run.sh bash`, which `exec`'s into
the running `web` container, and run `stripe login`.
