# ActsAsTaggableOn

Plugin to add tags to models: https://github.com/mbleigh/acts-as-taggable-on

* `name`: name of the tag
* `context`: "category" of the tag
* `taggable_type`: name of model where `acts_on_taggable` is set

### Database Tables

Tag and Taggings

* `Tag`: `ActsAsTaggable::Tag` - stores the tag name and count.
* `Tagging`: `ActsAsTaggable::Tagging` - "join" table that links `Tag` to the
  `Taggable`

A `Taggable` is the entity that is tagged. It's not db backed, but is a
polymorphic wrapper.

* `taggable_type`: Variation, Experiment, etc
* `context`: type of tag (page tag, tag, industry tag, etc)

Currently have:

* `Profile.industry_tag`
* `Variation.page_tag`
* `Variation.tag` (variation tags)


### Common tasks:

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

For queries `tag_list` is query-based and always loaded (not cached), so it's
best to avoid this method and do an in-memory `map(&:tag).pluck(:name)` to avoid
db.


### Removing / Modifying a Tag

`Tag` is HABTM relationship: `Tag` has_many `Taggings`, `Taggings`
belongs_to `Tag`

* `Tag` is `dependent: destroy`
* So `ActsAsTaggableOn::Tag.find(6).destroy` will delete dependent
  Taggings (avoid orphan)

For more surgical approaches:

* Remove the `Tagging`: removes the `Taggable`'s tag (entity no
  longer has tag, but tag can exist for others)
* Remove the `Tag` itself: make sure `Tagging` references do not exist
  to avoid orphans



