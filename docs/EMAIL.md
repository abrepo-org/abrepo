# Transactional Email

Moved off AWS because I couldn't get approved with ABrepo. I still
have personal us-east-2 approved, but fuck it.

Currently using **Mailersend** for transactional email only.

## Mailersend

* Uses SMTP, very straightforward (no policies, identities, etc)
* only dev and live modes.


## TODO: DNS Setup detail DMARC, DKIM, SPF records

Want to explain what all this is

---

## AWS SES- DEPRECATED

[Complete AWS SES Gist](https://gist.github.com/vergeman/653c806194c4b2c4ec37bf4a578b30b6)

* Additional information on DMARC, DKIM, SPF and DNS records


* SES Sending Authorization policies are set in us-east-2 to disallow
  emails sent by `test@abrepo.com` to anywhere except
  `test+N@abrepo.com` to preserve reputation / bounce.
  * SES -> Configuration: Verified Identities -> `test@abrepo.com`
  * See tab `Authorization` - "Sending authorization policies", policies below:


#### Sending Authorization Policies

These policies are set at verified users level

1. ALLOW emails from identity `test@abrepo.com` LIKE `test+*@abrepo.com`
2. DENY emails from identity `test@abrepo.com` NOT LIKE `test+*abrepo.com`

Note the `resource` field and proper region (us-east-2 prod, us-east-1 dev)

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "stmt1640453985894",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::976034468541:user/administrator.abrepo"
      },
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "arn:aws:ses:us-east-1:976034468541:identity/test@abrepo.com",
      "Condition": {
        "ForAllValues:StringLike": {
          "ses:Recipients": "test+*@abrepo.com"
        }
      }
    }
  ]
}

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "stmt1640454044451",
      "Effect": "Deny",
      "Principal": {
        "AWS": "arn:aws:iam::976034468541:user/administrator.abrepo"
      },
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "arn:aws:ses:us-east-1:976034468541:identity/test@abrepo.com",
      "Condition": {
        "ForAllValues:StringNotLike": {
          "ses:Recipients": "test+*@abrepo.com"
        }
      }
    }
  ]
}
```

#### SMTP: IAM vs SES Identity vs Sandbox

Sandbox:

* Operating Account (administrator) are default sandbox.
* Request live (non-sandbox) access per **region**.

"Easiest" setup is to silo region for production vs live.

Currently: us-east-2 is live, us-east-1 is dev.

SMTP:

* To access any SMTP server, need to create an IAM user per **region**.

* The IAM User has SMTP credentials (key id and pass) - looks like AWS
  keys but they are independent.

IAM Users:

* Account Pattern: ses-smtp-<service/team>-<project_name>-region
* `ses-smtp-abrepo.abrepo.us-east-2`: live
* `ses-smtp-abrepo.abrepo.us-east-1`: sandbox

Identities

* These are SES-Region unique identities that represent senders (or
  possible recipients for sandbox).
* They can have fine-tuned sender policies (send only to X addresses, etc)
* Want policies to guard against rampant sending and bounces. (Maintain reputation)
* SMTP access uses IAM-Region to access server, Identities are the
  multiple user "addresses" that use a SMTP server.

We really only want verified identities for dev. These are addresses
that will receive live emails. For prod just have generic domain for
sender.


#### Sandbox ENVS

Current dev / prod setup:

* production: us-east-2 as live (non-sandbox)
* dev: us-east-1 as sandbox


### SES Access Summary

us-east-1: sandbox
us-east-2: live (prod)

IAM accounts on each region (east-1, east-2)

SMTP server accessed with respective IAM account creds in .envs.

SMTP _Sender_ names:

* dev: test@abrepo.com
* prod: abrepo@abrepo.com

Identities:

* east-1 (dev sandbox): domain + users with policies
  * `test@abrepo.com`: attach sender authorization policies to allow
     only sends to `test+N@abrepo.com` in dev
* east-2 (prod): domain
