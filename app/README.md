# README

## Transaction Email

[Complete AWS SES Gist](https://gist.github.com/vergeman/653c806194c4b2c4ec37bf4a578b30b6)

* `dev` environment app email is `test@abrepo.com`
* `production` app email is `abrepo@abrepo.com`
* IAM policies are set in us-east-2 to disallow emails sent by
  `test@abrepo.com` to anywhere except `test+N@abrepo.com` to preserve
  reputation / bounce.
* No restrictions for prod sending (so can poison) - still in sandbox
  mode, awaiting approval.
* Devise Action Mailer errors are raises but quietly caught in
  ApplicationMailer so they don't crash the request (like dev mode setting ->
  `config.action_mailer.raise_delivery_errors = false`)
* Basically want to attempt transactional emails, but quietly catch
  errors to log them vs errors taking down the entire request.



## Notes

Migrations and Models

```
#can add foreign key (experiment_id) at migratin
$ rails g model Vendor name:string experiment:belongs_to

$ rails g migration AddPartNumberToProducts part_number:string

class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
  end
end

```
### Homepage Feed Brainstorm

Design and calculate quality / recency score, initial approach

---

Caveats:

* Need to return scopes to pass to policy and pagination.
* `limit` on query can affect pagination results (break)

~~0. sort by "new", add pagination~~

Current: initially calculates a "quality" score / recency:
`Experiment.calcrank` contains initial attempt. Need to return scopes.

* `Experiment.calcscore`: is an average count of the diffs contained
  in each child variation/renderable. This average is then run through
  a poisson distribution with mean 3 to get a pdf value - which serves
  as the score.
* The working idea is that experiments with a few diffs are likely to
  be decent, but those with a large number of diffs are likely noiser
  and of lesser "quality". So range 1-5 are strong, but anything
  beyond tapers off in rank.
* Decay / Recency is epoch current_time - epoch created_at, calculated
  at runtime for in database query and ordered accordingly.

Anticipate improving this later. There's no real "science" behind this
scoring.

---

2. add visits/clicks score input; promote? wouldn't we want more popular tests? demote personal, promote global?
3. quality score is combination of commentary exists, summaries, tags - the more "informative" and complete an experiment is, the higher score it gets.
4. (quality, visitor, date, affinity): affinity some score of personal preference
5. notion of diversity/ browsing

phase 2: ask for user preferences onboarding, edit user settings
present a list of topN companies, industries, and checkbox

later:
phase 3: tracking - logging users behavior into warehouse (segment.js)
phase 4: building a user preferences model from data

---

Feed of experiments

* recency/date
* popularity (views?), up/down votes - weird with a paid product- like
  who are these other people deciding things for me
* search/tag clicktrack interests


### Authorization Basics / Notes via Pundit

Authorization is "contained" in `/app/policies` directory via gem [Pundit](https://github.com/varvet/pundit)

Current "role" is a simple boolean for`user.moderator`.

##### Importer User

There is a seed `importer` user
in [db/seeds.rb](/blob/master/app/db/seeds.rb) with password in
`.env`. To be able to submit from abannotate, current browser session
must be logged in as `importer` user. CORS request is enabled via
`rack-cors`, with accepted origins as `localhost:4000` and
`127.0.0.1:4000` - as indicated in abannotate browser. AuthN
credentials are passed via fetch for the import request.


##### Policies

Authorization policies are designed as extensions to resources; currently:

* `policies/ExperimentPolicy.rb`
* `policies/VariationPolicy.rb`

Each policy has a number of boolean methods that correspond to a
controller action, e.g.:

```
def create?
  user.moderator?
end
```

This sets a policy to "gate" the 'create' action for that resource.

The actual call to check authorization is in the controller via the
`authorize` method, which is wrapped around the class or instance.

```
experiment = authorize Experiment.find(id: 123)
```


##### Scope

Authorization entails a restricted view of resources, done via an
added `Scope` class in the respective policy.

This definition is then applied throughout controllers or views via a
decorator `policy_scope` chainable method.

```
# app/views/variations/index.html.erb

filtered_variations = policy_scope(@experiment.variations).where(...)

```

##### Notes

* `policy_scope`, `authorize` aren't available in models; these are
  controller/view helpers. But can dependency inject them in
  controller to helper models; e.g. see
  `search_controller#index`, and `models/search.rb`

* `user` in policy referenced as `current_user` (devise-friendly)
  automatically in pundit. However, this requires rescue when
  there is no logged in user (user is nil)

* unauthorized cases throw an error and require catching: `rescue_From
  Pundit::NotAuthorizedError, with: :user_helper_method` typically
  added to a controller.






### ActsAsTaggableOn

Plugin to add tags to models: https://github.com/mbleigh/acts-as-taggable-on

`name`: name of the tag
`context`: "category" of the tag
`taggable_type`: name of model where `acts_on_taggable` is set


Currently have:

* `Profile.industry_tag`
* `Variation.page_tag`
* `Variation.tag` (variation tags)


Common tasks:

* Find records with tags: `<Model>.tagged_with(<tag>)`
* Find tag: ActsAsTaggableOn::Tag.where(<query>)
* Find tags with context:

```
    #NB: join attributes are available but not explicitly displayed in
    #Active Record assocation
    #Taggable_type: model, context: tag "category"
    @tags = ActsAsTaggableOn::Tag
              .joins(:taggings)
              .where(name: tags)
              .where("#{ActsAsTaggableOn.taggings_table}.taggable_type IN (?)",
                     ["Variation"])
              .select(:id, :name, :context)
              .distinct

    @industries = ActsAsTaggableOn::Tag
                    .joins(:taggings)
                    .where(name: industries)
                    .where("#{ActsAsTaggableOn.taggings_table}.taggable_type IN (?)",
                           ["Profile"])
                    .select(:id, :name, :context)
                    .distinct

```

### pg_search

* General approach is to have ExpVar data as general multisearch corpus
* augmented by scopes to filter query result given tags, additional information
* accessed via a singular query route: `POST /search` with multiple querystring params:
  * `q=`: freetext query
  * `industries=`: industry tags
  * `tags=`: expvar tags
  * `companies=`: company domain ? want higher guarantee of uniqueness

#### Multisearch: multi-model, global index

To rebuild indices:

* `rake pg_search:multisearch:rebuild[Campaign]`
* `rake pg_search:multisearch:rebuild[Experiment]`
* `rake pg_search:multisearch:rebuild[Variation]`
* `rake pg_search:multisearch:rebuild[Audience]`

To destroy / remove indices:

* need custom rake task to call:
  `PgSearch::Document.delete_by(searchable_type: "Audience")`


#####

* To add `additional_attributes`, need to explicitly state add column
and index in a migration to `pg_search_documents` table.

* Search scope rank: To retrieve the rank, call `.with_pg_search_rank`
  on a scope, and then call `.pg_search_rank` on a returned record.




### Caching

Need to enable caching in dev mode to see results (default in
uncached). Toggle back and forth:

`rails dev:cache`

* Try to cache results; primitives, or ids for primary key lookup (faster)
* If not caching, check you're not inadvertently caching an active
  record relation (scope) - which is just the query, not the results.


#### Fragment Caching

In views: can cache a block - need to *watch cache key dependencies*.

If looping over an has_many association; likely need to add
`touch:true` on model 's association attribute (belongs_to) to trigger
dirty and a cache reload while loop.


```
<% cache(key, expires_in: 30.seconds) do %>
    <%= render xyz %>
<% end %>
```

#### Low level Caching

Ideally put in model, but can be placed in helpers

```

def cache_helper_fn_for(instance)
    Rails.cache.fetch("#{instance.cache_key_with_version}/cache_helper_fn_for", expires_in: 30.seconds) do
      <cachable calculation>
    end
end

```

#### Collection Partial Caching

Defer to the render function caching key, looping - just need a singular
partial to render the element. Internal counter (example below
`variation_counter`) as auto counter variable made available in partial.

Big issue: need to be careful with counters and especially helper functions.

Cache busts on updated_at object change, the internal counter (index)
will start at 0, regardless of position in collection (as it's fresh count).

Can cause problems in helpers.



```

<%= render partial: '/shared/expvar_variation', collection: variations,
    as: :variation,
    locals: {variations: variations}, cached: true %>

```



### Imports Controller Logic

#### When to update, when to create

* PCEV: the "keys" are `vendor_id` and `a_id` (abannotate mongo
  _id). We check for a match, and create entries accordingly.
  * new: the `vendor_id` won't exist, so it will be added
  * removed: submission `vendor_id` won't exist
  * ^^ these require on a comparison check per submission.
  * changed: the `a_id` will be different from a unique contentHash,
    generated by abextract. Will have to sort by crawlId.

* Action, Renderable, Diffs: these will be deleted and regenerated
  as they are fully "generated" off of "raw" inputs.
  * unless contain a different crawlID, replace each
    action/renderable/diffs.
  * a submission with different crawlId might indicate underlying
    page redesign, but same running experiment). These would be added.
  * variation will need to sort and filter action and renderables by last crawlId.
  * Diffs are basically handled at abannotate (no concept of orphan in
    abrepo - any submission means orphan concern handled in abrepo;
    presence follows renderable)


#### Submission

* Visit `/imports` as user `importer` to see queue of submitted
  ExpVars that require review.

* Update changes, and resubmit from ABAnno as often as needed. Set to overwrite.

* On submit the ExpVar is set to `published:true` and becomes visible
  to public.

* Note `Experiment` and `Variation` are independently toggled.


### Users

#### Devise Generated Views: Styling Updates

##### Supporting Views:

* `devise/shared/error_messages`:
    * `<div id="error_expanation">`, `<h2>` error title, `<ul>` of `<li>` message
* `devise/shared/links`: underneath page forms - mostly `href` and `<br />`, no style
* `/devise/mailer/*.rb`: plain text - `<p>` tags, no style

##### Main Style Changes with Devise

* `.field`: `<label>`, `<email_field`>
    * `<label>` add class "label"
    * `<label>` remove `<br/>`
    * wrap input with `<div class="control">`
    * `<label>` example with converted helper text:
<pre>
          <%= f.label :password, class: "label" do%>
          Password
          <span class="help has-text-weight-normal is-inline-block">
              (leave blank if you don't want to change it)
          </span>
          <% end  %>

</pre>

* `.actions`: `<submit>`
    * wrap with `<div class='control'>`, add `class: 'button is-fullwidth-desktop is-link'`
    * is-fullwidth-desktop custom class
* change min password length
* change links text
* error message list needs some styling e.g.: `http://localhost/users/unlock`:
    * "error confirmation": 1 error prohibited this user from being saved
    * Bulma styles for "Notification"
    * add "notification class" wrapper; add `<button> delete`
    * remove `<h2>`
    * adjust `<ul>` margin-top; mt-0

* use `content_for(:devise)` block to isolate devise views in its own separate layout
    * exceptions: user settings so not standalone `content_for`
        * `registrations/edit.html.erb`
        * `passwords/edit.html.erb`


* error message displayed:
    * `<%= resource.errors.inspect %>`
    * access each attribute error message: e.g. `<%= resource.errors[:email].join(',') if resource.errors[:email] %>`

Login page error messages use flash

    * There is a error_message devise_helper 'converter': https://stackoverflow.com/questions/4635986/rails-devise-error-messages-when-signing-in
    * Flash approach:

``` erb
<% if flash[:error] || flash[:notice] || flash[:alert] %>
    <div class="notification is-danger is-light">
        <button class="delete"></button>
        <%= content_tag(:div, flash[:error], :id => "flash_error") if flash[:error] %>
        <%= content_tag(:div, flash[:notice], :id => "flash_notice") if flash[:notice] %>
        <%= content_tag(:div, flash[:alert], :id => "flash_alert") if flash[:alert] %>
    </div>
<% end %>

```


##### Pages:

```

        new_user_session GET    /users/sign_in(.:format)          devise/sessions#new
       new_user_password GET    /users/password/new(.:format)     devise/passwords#new
      edit_user_password GET    /users/password/edit(.:format)    devise/passwords#edit
   new_user_registration GET    /users/sign_up(.:format)          devise/registrations#new
  edit_user_registration GET    /users/edit(.:format)             devise/registrations#edit
   new_user_confirmation GET    /users/confirmation/new(.:format) devise/confirmations#new
         new_user_unlock GET    /users/unlock/new(.:format)       devise/unlocks#new
             user_unlock GET    /users/unlock(.:format)           devise/unlocks#show


```


## Favicons

https://redketchup.io/favicon-generator


---

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
