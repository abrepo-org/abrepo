# Shutdown

General Shutdown Notes

Order

1. Domains
  * moved from cloudflare biz to cloudflare personal
2. Hosting: move/add personal account owner, close "empty" biz account
 * AWS
 * DO
 * Heztner
3. DBA Abandon via SOSUpload (not LLC)
4. Analytics / SEO
 * add personal acct as ownership
 * remove property, account from biz owner
5. Gmail / Google workspace account cancel
 * replace with Cloudflare email routing to keep access to email addresses
5. Stripe
 * remove code paths using live library
6. UFCU bank account
7. LLC

## LLC/DBA

* DBA: abandon assumed name form
  * fill out, sign, then scan submit via SOSUpload.
  * SOSUpload is basically online document submission for forms that don't exist
    on SOSDirect.
  * poorly advertised

* Certificate of Account Standing
  * Before closing LLC, requires a "Certificate of Account Status" generated from Texas Comptroller
    * Form received is 05-305 generated.
  * Indicates no tax owed.

* LLC: Texas, go on SOSDirect
  * login, enter the "File Number" - 0804XXXX... go to "Find Document"
  * Termination of Entity
    * attach/upload Certificate of Account Standing


## Digital Ocean

1. Login as business account
2. Invite Takeover (personal) account to Team
3. Elevate personal account to "Owner"
4. Personal: change team contact email
5. Personal: remove business payment from team
6. Business: Deactivate account
7. Replace DO Token (see DO API Tab) with Takeover / personal account's generated DO Token
   * abrepo ops: Packer, Terraform, Ansible - see .env's
   * backup biz .env to .env.quirkshopllc, and replaced with .env personal
8. Shutdown business acount - personal is now sole owner of team


## Cloudflare

1. Move over all domains to personal
   * export / import DNS records
   * export / import WAF rules (copy expression)
   * verify domain SSL type is the same
   * export page rules (root redirects to www)
     * e.g. `abrepo.com/*` -> forwarding url 302 to `https://www.abrepo.com/$1`
2. Replace any API tokens with personal ones
   * Typically terraform whitelist ip ranges of CF servers
3. Remove payment methods
4. Don't close account yet, but just let orphan for now. (Still has receipts,
   once closed email can't be used again)

## Google

### Analytics / Search Console

Make sure logged in as business. These were under workspace account domain
address.

* Google Analytics
  * add personal account as 'owner' level
  * settings -> remove as owner
* Search Console
  * add personal account user as 'owner' to property
  * settings -> remove property (as business owner)

### Gmail Workspace

* export copy of mail / workspace services using Google Takeout (takes a while)
  * make sure to export any GScript associated with sheets manually if want
    easily accessible to reference
* enable email routing via cloudflare per domain
* remove/replace appropriate MX records


## AWS

### AWS Organizations

#### Hierarchy

1. nameless "root" creates manager account
   * stashcredentials, never use root again.
2. create IAM administrator user - this is operating account.
3. manager account creates member accounts (these are "sub-root")
4. New Member account
   * stash credentials, never use root again
5. create IAM administrator user - this is operating account.
...

#### Moving AWS Organizations

e.g. From Company to Personal. This preserves all assets, keys, configs, etc.

1. Host AWS Organization invites member root
2. Target Member root: added new default payment card
3. Leave org button -> need to sign up as standalone account (basic)
   * go through verification captcha, sms
4. Now account is standalone, can leave org
5. AWS invite - join host organization
6. Update contact information

## Stripe

1. Remove code (and tests) that rely on live Stripe calls;
   * library is ok, can stub objects
2. Remove any user flow that rely on subscriptions

## UFCU Banking

* Just pop in, show ID.
* will cut a cashier's check on the spot for any balance.
* Takes 5 min.

