# PG_Search Notes

### Rebuilding index

After a bunch of imports, need to rebuild the index. Only used for
multisearchable corpus/inputs:

```
# NB: note the []

rake pg_search:multisearch:rebuild[Variation]

```

### Relevance

Current pg_search inputs are via `Variation` and `Profile`
models. These include references to `Taggables`.

The `Search` model builds a query and executes them.

#### Relevance Problem

Issue with highlighting relevance of results.

Inserting tags (Variation [tag_list, page_tag_list], Profile
[industry_tag_list]) into the search_scopes makes it difficult to determine
relevance. e.g. Sometimes you have to stare at the results to wonder why it was
returned (industry isn't apparent, etc.)

Approaches:

1. Highlighting some aspect of the result (eg the company industry, or
   tag, description, etc)

2. Filtering the query at the autocomplete step: e.g. results by
   query, results by tags

3. Labeled results? break down results according to scopes? This is
   probably easiest.
