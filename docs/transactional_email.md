# Transactional Email

Using **Mailersend** for transactional email only.

## Mailersend

* Uses SMTP, very straightforward (no policies, identities, etc)
* only dev and live modes.
* see `.env`: transactional email currently sent from root
  `abrepo.com` domain
  * prod: abrepo@abrepo.com
  * dev: test@abrepo.com

## DNS Setup detail DMARC, DKIM, SPF records

[See ABLeadCrawl Project](https://github.com/abrepo-org/ableadcrawl/blob/master/README.md)

## Rails Transaction Email

* Devise Action Mailer errors are raised but quietly caught in
  `ApplicationMailer` so they don't crash the request (like dev mode setting ->
  `config.action_mailer.raise_delivery_errors = false`)

* Basically want to attempt transactional emails, but quietly catch
  errors to log them vs errors crashing the entire request.
