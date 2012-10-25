# Heroku Notifications Plugin

A keikoku consumer for the heroku CLI

### Installation

```
heroku plugins:install git://github.com/hgmnz/heroku-notifications.git
```

### Usage

```
$ heroku notifications
=== HEROKU_POSTGRESQL_BLACK on app hgmnz
[emergency] Database exceeded its row limits and access has been revoked.
More info: https://devcenter.heroku.com/articles/heroku-postgres-starter-tier#limits

=== HEROKU_POSTGRESQL_VIOLET on app keikoku
[warning] Database exceeded its row limits. Access to be revoked in 7 days.
More info: https://devcenter.heroku.com/articles/heroku-postgres-starter-tier#limits

=== HEROKU_POSTGRESQL_BLUE on app myapp
[info] Database reaching its row limits.
More info: https://devcenter.heroku.com/articles/heroku-postgres-starter-tier#limits
$ heroku notifications
No notifications.
```

## THIS IS BETA SOFTWARE

Thanks for trying it out. If you find any issues or would like to provide
feedback, please let us know at support@heroku.com
