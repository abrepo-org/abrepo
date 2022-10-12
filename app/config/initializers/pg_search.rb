#prefix: partial match
#dictionary: stemming (e.g. neuters suffix)

PgSearch.multisearch_options = {
  using: {
    tsearch: {
      prefix: true,
      any_word: true,
      dictionary: 'english',
      highlight: {
        StartSel: '<span class="search-highlight-text">',
        StopSel: '</span>',
        HighlightAll: true,
        MaxFragments: 1
      }
    }
  }
}
