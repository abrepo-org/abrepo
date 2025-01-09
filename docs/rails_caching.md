# Rails Caching

Need to enable caching in dev mode to see results (default in uncached). Toggle
back and forth:

`rails dev:cache`

* Try to cache results; primitives, or ids for primary key lookup (faster)
* If not caching, check you're not inadvertently caching an active record
  relation (scope) - which is just the query, not the results.

### Fragment Caching

In views: can cache a block - need to *watch cache key dependencies*.

If looping over a `has_many` association; likely need to add `touch:true` on
model 's association attribute (belongs_to) to trigger dirty and a cache reload
while loop.


```
<% cache(key, expires_in: 30.seconds) do %>
    <%= render xyz %>
<% end %>
```

### Low level Caching

Ideally put in model, but can be placed in helpers

```

def cache_helper_fn_for(instance)
    Rails.cache.fetch("#{instance.cache_key_with_version}/cache_helper_fn_for", expires_in: 30.seconds) do
      <cachable calculation>
    end
end

```

### Collection Partial Caching

Defer to the internal render function caching key; when looping - use a singular
partial to render the element. Internal counter (example below
`variation_counter`) as auto counter variable is made available in partial.

Big issue: need to be careful with counters: especially helper functions and
positions within collection.

Cache busts on updated_at object change, the internal counter (index) will start
at 0, regardless of position in collection (as it's fresh count).

Can cause problems in helpers.


```

<%= render partial: '/shared/expvar_variation',
    collection: variations,
    as: :variation,
    locals: {variations: variations},
    cached: true %>

```


### Cache Busting / Clearing

* File system cache: `rake tmp:cache:clear`
* default "in-memory" cache: `Rails.cache.clear`
  * This is the current default used for view fragment caches

To clear cache, execute in Rails console live: `bundle exec rails c;
Rails.cache.clear`. Might need to do this in prod live since cache keys are
often manually chosen, I inadvertently might forget to include a model, etc.
