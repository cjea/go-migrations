start-db:
		docker start cj-test-db || echo "Creating DB . . . " && \
			docker run -dt --name cj-test-db -p 5432:5432 postgres:10.4-alpine

stop-db:
		docker stop cj-test-db

run-schema:
		psql --user=postgres --host=localhost --file=./schema.sql

psql:
	psql -h localhost -U postgres

build:
	if [ -e "main" ] ; \
	then \
		rm main ; \
	fi; \
	go build main.go

up:
	./main --path=migrations/

down:
	./main --path=migrations/ -dir=down

drop:
	./main drop
