## Data Import Process - Importer

Content is submitted to the app by an `importer` user - a user flagged with
moderator.

### Importer User

There is a seed `importer` user in [db/seeds.rb](./db/seeds.rb).

To be able to submit from `abannotate`, user in current browser session must be
logged in to `abrepo` web app as the `importer` user.

The importer process is meant to run and submit from a local machine for the
time being.

##### Importer and CORS

CORS is enabled via `rack-cors`, with accepted origins as `localhost:4000` and
`127.0.0.1:4000` - as indicated in abannotate browser. AuthN credentials are
passed via fetch for the import request.

NB: CORS allows the request server-side, but to prevent CSRF and for
privacy considerations, most browsers now prevent 3rd party cookies.

We need 3rd party cookies for to allow authenticated POST requests to
`/importer` route.

We send requests cross-domain (to localhost, or abrepo.com). For auth purposes,
the session cookies need to be sent, which is a cross-domain request.

We can allow this via adding the cookie owner domains as an exception
in Firefox:

`Settings -> Privacy & Security -> Cookies and Site Data -> Manage Exceptions`

add domains: `localhost` and `abrepo.com`

There is similar option for chrome but I am too lazy atm.

### Imports Controller Logic

#### When to update, when to create

* PCEV: the "keys" are `vendor_id` and `a_id` (abannotate mongo _id). We check
  for a match, and create entries accordingly.
  * new: the `vendor_id` won't exist, so it will be added
  * changed: the `a_id` will be different from a unique contentHash, generated
    by abextract. Will have to sort by crawlId.
  * removed: submission `vendor_id` won't exist
  * ^^ these require on a comparison check per submission.

* Action, Renderable, Diffs: these will be deleted and regenerated as they are
  fully "generated" off of "raw" inputs.
  * unless contain a different crawlID, replace each action/renderable/diffs.
  * variation will need to sort and filter action and renderables by last
    crawlId.
  * a submission with different crawlId might indicate underlying
    page redesign, but same running experiment). These would be added.
  * Diffs are basically handled at abannotate (no concept of orphan in abrepo -
    any submission means orphan concern handled in abrepo; presence follows
    renderable)


#### Submission PRocess

* Visit `/imports` as user `importer` to see queue of submitted ExpVars that
  require review.

* Update changes, and resubmit from ABAnno as often as needed. Set to overwrite.

* On submit the ExpVar is set to `published:true` and becomes visible to public.

* Note `Experiment` and `Variation` are independently toggled.
