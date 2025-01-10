# Rails Testing

Using minitest.

### Syntax

* `assert_response` : controller response
* `assert assigns(:variations).present?`: checks for instance variable
* `assert_template /path`: asserts view template rendered

### Gotchas

Fixtures are generated in `test/fixtures/`, but values typically need to be populated.

* fixture top level key is it's instance variable name (e.g. "profile_one")
* associations: make sure the foreign key `_id` field is replaced by the instance
  * e.g. `Profile` has_many `Experiments`, make sure `experiments.profile_id` is
    `experiments.profile: profile_one`

If associations are still not forming, ensure the instances are valid:

```
# profiles references the contents of fixture file (profiles.yml)
@profile_one = profiles(:profile_one)
@profile_one.valid?
```

#### ActsAsTaggable / Tag fixtures

For models with tags, the associated tag fixtures need to be created.

These need to be placed in a subdirectory, 'acts_as_taggable_on/tags.yml' to be
properly loaded by test suite.

For something like `Taggings` fixture - helps to look at attributes in console
as reference to populate. e.g. `Taggings.taggable_type` needs a fixture value
for associations to take.
