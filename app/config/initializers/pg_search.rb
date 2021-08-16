#prefix: partial match
#dictionary: stemming (e.g. neuters suffix)

PgSearch.multisearch_options = {
  using: {
    tsearch: {
      prefix: true,
      dictionary: 'english'
    }
  }
}
