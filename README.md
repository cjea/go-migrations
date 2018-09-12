## go migrations

using golang-migrate to set up basic migrations against a postgres db

```
./migrate up
docker exec cj-test-db psql -h localhost -U postgres -c \
  "SELECT * FROM NEXANS;"
./migrate down
```
