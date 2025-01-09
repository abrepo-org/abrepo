## Home Feed CalcRank Brainstorm

Design and calculate quality / recency score, initial approach

Caveats:

* Need to return scopes to pass to policy and pagination.
* `limit` on query can affect pagination results (break)

Current: initially calculates a "quality" score / recency:

`Experiment.calcrank` contains initial attempt. Need to return scopes.

* `Experiment.calcscore`: is an average count of the diffs contained in each
  child variation/renderable. This average is then run through a poisson
  distribution with mean 3 to get a pdf value - which serves as the score.

* The working idea is that experiments with a few diffs are likely to be decent,
  but those with a large number of diffs are likely noiser and of lesser
  "quality". So range 1-5 are strong, but anything beyond tapers off in rank.

* Decay / Recency is epoch current_time - epoch created_at, calculated
  at runtime for in database query and ordered accordingly.

Anticipate improving this later. There's no real "science" behind this
scoring.

---

*  add visits/clicks score input; promote? wouldn't we want more popular tests?
   demote personal, promote global?
*  quality score is combination of commentary exists, summaries, tags - the more
   "informative" and complete an experiment is, the higher score it gets.
* (quality, visitor, date, affinity): affinity some score of personal preference
*  notion of diversity/ browsing

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


