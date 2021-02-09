# Devise Stripe Flow

Assume any sign-up is a prelude to a purchase. So our `/users/sign-up`
is a decorated vanilla sign up with "purchase step" indicators

### checkout/initial/:price_key (users/sign-up)

1. user selects plan on landing page, anywhere on site
2. user visits `/checkout/start/:price_key` -> "cloaked" users/sign_up
3. Create account. On success `after_sign_up_path` redirects to
   `/checkout/review/:price_key`
4. Checkout reviews the selected plan, and launches stripe session_id
   request and redirect.
5. Hands off to stripe.

### /checkout/review/:price_key

If no price_id; defaults to 'basic' (monthly)

This is a checkout, purchase review page; only accessible by logged in
users.

Displays plan and features, price, etc.

Just a single button that says "purchase", runs stripe checkout
process: (fetch session_id, then stripe_redirect)



## Devise

Checkout controller consists of devise registrations controller overrides, and
stripe paths.

`checkout#initial`-> `registrations#new` (both action and view)
`checkout#create` -> `registrations#create`

Mostly copied controller code into `/checkout` with slight url
modifications, sign_in checks.

Use separate named actions to allow custom before hook behavior.

#### Views

`/checkout`:

* `initial.html.erb` is `#new` page for user creation
* `review.html.erb`: reviews created users selection and sends to stripe


#### Routes

* get `checkout/initial/:price_key` -> new
* post `checkout/initial/:price_key` -> create
* get `checkout/review/:price_key` -> stripe launch

`price_key` is a param for which subscription plan.
