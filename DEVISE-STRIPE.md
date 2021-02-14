# Devise Stripe Flow - XHR EDITION

Assume any sign-up is a prelude to a purchase. So our `/users/sign-up`
is a decorated vanilla sign up with "purchase step" indicators

### checkout/account/:lookup_key (users/sign-up)

1. user selects plan on landing page, anywhere on site
2. user visits `/checkout/account/:price_key` -> POST request with
   credentials: step 3-5 are controller codde from single POST
   request.
3. Attempts user account creation; returns `error` object or `user.ok`
4. Successful account, creates Stripe session token and returns to client the `session_id`.
5. Client receives `user.ok` and `stripe.ok`, redirects to Stripe.
6. On success `after_sign_up_path` redirects to `/checkout/success`

### /checkout/subscribe/:lookup_key

This route exists in case of a cancelled stripe payment, or
subscription expiry, cancel. This is a registered user state with no
active subscription.

This page for this type of user is presented with the change to subscribe.

If no `lookup_key`; uses default ('basic-monthly')

Click "purchase", runs stripe checkout process: (create session_id,
then stripe_redirect)

## Stripe

Requires default `lookup_key` in `.env` as
`STRIPE_DEFAULT_LOOKUP_KEY`. This is a default / fallback stripe
lookup_key.


## Devise

Checkout controller consists of devise registrations controller
overrides. stripe_controller deals with post authenticated user, and
setting up Stripe's checkout session object to hand off to Stripe's
servers.

`checkout#account`-> copies `registrations#new` (both action and view)
`checkout#create` -> copies `registrations#create`
`stripe#review` -> post user, vanilla controller.

Mostly copied controller code into `/checkout` with slight url
modifications, sign_in checks.

Use separate named actions to allow custom before hook behavior.

`checkout_controller` inherits from devise
`Stripe_controller` are stripe-specific.

#### Views

`/checkout`:
* `account.html.erb` is `#new` page for user creation

`/stripe`:
* `cancel.html.erb`: stripe sends on canceled payment
* `success.html.erb`: stripe sends on successful payment
* `subscribe.html.erb`: post user creation in unsubscribed state;
  review allows js to execute with selected plan and user, hands off to stripe
    * this is an extra step, but a single user-creation + checkout
      would require creating users via xhr, which we'll defer later.

#### Subscription Creation

on `webhooks/` event `checkout.session.completed`, a `Subscription`
object is created for that user. Creation also attempted when user
visits `/success`.

Does a `first_or_create` in order to set user access in the event the
webhook event is delayed, doesn't reach.


#### Routes

* get `checkout/account/:lookup` -> new
* post `checkout/account/:lookup_key` -> create
* get `checkout/subscribe/:lookup_key` -> stripe launch

`lookup_key` is a param for the corresponding Stripe `lookup_key` (plan.)
