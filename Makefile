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

image:
	docker image build . -t money-migrator

network:
	docker network create migration-network || true

connect-db: network
	docker network connect migration-network cj-test-db || true

up: image connect-db
	docker run --rm -it \
		--network=migration-network \
		--volume="$(PWD)/migrations:/migrations" \
		money-migrator \
		migrate \
			-database "postgres://postgres@cj-test-db/postgres?sslmode=disable" \
			-source "file:///migrations" \
			up

down: image connect-db
	docker run --rm \
		--network=migration-network \
		--volume="$(PWD)/migrations:/migrations" \
		money-migrator \
		migrate \
			-database "postgres://postgres@cj-test-db/postgres?sslmode=disable" \
			-source "file:///migrations" \
			down

drop: image connect-db
	docker run --rm \
		--network=migration-network \
		--volume="$(PWD)/migrations:/migrations" \
		money-migrator \
		migrate \
			-database "postgres://postgres@cj-test-db/postgres?sslmode=disable" \
			-source "file:///migrations" \
			drop
