# irceeingurimgs

Simplest image sharing web app ever

## Cron command

`0 * * * * find $LOCATION/images -type f -mmin +1440 -delete`