# Heroku Notifications Plugin

A keikoku consumer for the heroku CLI

```
$ heroku notifications
=== Notifications for harold@heroku.com (2)
HEROKU_POSTGRESQL_BLACK on app hgmnz
  [emergency] Database HEROKU_POSTGRESQL_BLACK_URL on hgmnz exceeded it's row limits and access has been revoked
  More info: https://devcenter.heroku.com/articles/heroku-postgres-starter-tier#limits

HEROKU_POSTGRESQL_VIOLET on app keikoku
  [warning] Database HEROKU_POSTGRESQL_VIOLET_URL on keikoku exceeded it's row limits. Access to be revoked in 7 days.
  More info: https://devcenter.heroku.com/articles/heroku-postgres-starter-tier#limits
$ heroku notifications
harold@heroku.com has no notifications.
```
