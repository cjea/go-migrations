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
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
		go build main.go

up:
	./main --path=migrations/

down:
	./main --path=migrations/ -kind=down

drop:
	./main drop

image:
	docker image build . -t money-migrator

money-up: build image
	docker run --rm \
		--network=host \
		--name=money-migrator \
		--entrypoint /main \
		money-migrator \
		-path migrations/ -kind up

money-down: build image
	docker run --rm \
		--network=host \
		--name=money-migrator \
		--entrypoint /main \
		money-migrator \
		-path migrations/ -kind down

money-drop: build image
	docker run --rm \
		--network=host \
		--name=money-migrator \
		--entrypoint /main \
		money-migrator \
		drop
