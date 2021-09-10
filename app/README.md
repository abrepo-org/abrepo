# README


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

initial:

0. sort by "new", add pagination
1. initially calculate a quality score vs recency - have a fixed list (top 100), then link to sort by new - how Stack overflow does it

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

feed of experiments

* recency/date
* popularity (views?), up/down votes - weird with a paid product- like
  who are these other people deciding things for me
* search/tag clicktrack interests
* signup interests from onboarding



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
