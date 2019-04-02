# ABRepo

Rails based frontend for abrepo web app

## Rails Notes

* Need to rebuild image when doing a gem bundle install (standalone
  bundle install installs, but docker run is ephemeral)


* Permission issues? Try clearing cache generated as route.

```
(sudo) rake tmp:cache:clear
```
