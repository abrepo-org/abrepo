# PG_Search Notes

* General approach is to have ExpVar data as general multisearch
  corpus
* augmented by scopes to filter query result given tags, additional information
* accessed via a singular query route: `POST /search` with multiple querystring params:
  * `q=`: freetext query
  * `industries=`: industry tags
  * `tags=`: expvar tags
  * `companies=`: company domain ? want higher guarantee of uniqueness

#### Multisearch: multi-model, global index

To rebuild indices:

```
rake pg_search:multisearch:rebuild[Campaign]
rake pg_search:multisearch:rebuild[Experiment]
rake pg_search:multisearch:rebuild[Variation]
rake pg_search:multisearch:rebuild[Audience]
```

* To destroy / remove indices, need custom rake task to call:
`PgSearch::Document.delete_by(searchable_type: "Audience")`

* To add `additional_attributes`, need to explicitly state add column and index
in a migration to `pg_search_documents` table.

* Search scope rank: To retrieve the rank, call `.with_pg_search_rank` on a
  scope, and then call `.pg_search_rank` on a returned record.


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
