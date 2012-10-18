# Heroku Notifications Plugin

A keikoku consumer for the heroku CLI

```
$ heroku notifications
=== Notifications for harold@heroku.com (3)
HEROKU_POSTGRESQL_BLACK on app hgmnz
  [emergency] Database exceeded its row limits and access has been revoked.
  More info: https://devcenter.heroku.com/articles/heroku-postgres-starter-tier#limits

HEROKU_POSTGRESQL_VIOLET on app keikoku
  [warning] Database exceeded its row limits. Access to be revoked in 7 days.
  More info: https://devcenter.heroku.com/articles/heroku-postgres-starter-tier#limits

HEROKU_POSTGRESQL_BLUE on app keikoku
  [info] Database reaching its row limits.
  More info: https://devcenter.heroku.com/articles/heroku-postgres-starter-tier#limits
$ heroku notifications
harold@heroku.com has no notifications.
```
