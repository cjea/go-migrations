DB := cj-test-db
MIGRATOR_IMAGE := migrator
MIGRATION_NETWORK := migration-network

start-db:
		docker start "$(DB)" || echo "Creating DB . . . " && \
			docker run -dt --name "$(DB)" -p 5432:5432 postgres:10.4-alpine

stop-db:
		docker stop "$(DB)"

run-schema:
		psql --user=postgres --host=localhost --file=./schema.sql

psql:
	psql -h localhost -U postgres

build:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
		go build main.go

image:
	docker image build . -t "$(MIGRATOR_IMAGE)"

network:
	docker network create "$(MIGRATION_NETWORK)" || true

connect-db: network
	docker network connect "$(MIGRATION_NETWORK)" "$(DB)" || true

up: image connect-db
	docker run --rm -it \
		--network="$(MIGRATION_NETWORK)" \
		--volume="$(PWD)/migrations:/migrations" \
		"$(MIGRATOR_IMAGE)" \
		migrate \
			-database "postgres://postgres@$(DB)/postgres?sslmode=disable" \
			-source "file:///migrations" \
			up

down: image connect-db
	docker run --rm \
		--network="$(MIGRATION_NETWORK)" \
		--volume="$(PWD)/migrations:/migrations" \
		"$(MIGRATOR_IMAGE)" \
		migrate \
			-database "postgres://postgres@$(DB)/postgres?sslmode=disable" \
			-source "file:///migrations" \
			down

drop: image connect-db
	docker run --rm \
		--network="$(MIGRATION_NETWORK)" \
		--volume="$(PWD)/migrations:/migrations" \
		"$(MIGRATOR_IMAGE)" \
		migrate \
			-database "postgres://postgres@$(DB)/postgres?sslmode=disable" \
			-source "file:///migrations" \
			drop

migrate: image connect-db
	docker run --rm \
	--network="$(MIGRATION_NETWORK)" \
	--volume="$(PWD)/migrations:/migrations" \
	"$(MIGRATOR_IMAGE)" \
	migrate \
		-database "postgres://postgres@$(DB)/postgres?sslmode=disable" \
		-source "file:///migrations" \
		$(cmd)
