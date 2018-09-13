DB_HOST := cj-test-db
DB_DSN := postgres://postgres@$(DB_HOST)/postgres?sslmode=disable
MIGRATOR_IMAGE := migrator
MIGRATION_NETWORK := migration-network

start-db:
		docker start "$(DB_HOST)" || echo "Creating DB . . . " && \
			docker run -dt --name "$(DB_HOST)" -p 5432:5432 postgres:10.4-alpine

stop-db:
		docker stop "$(DB_HOST)"

image:
	docker image build . -t "$(MIGRATOR_IMAGE)"

network:
	docker network create "$(MIGRATION_NETWORK)" || true

connect-db: network
	docker network connect "$(MIGRATION_NETWORK)" "$(DB_HOST)" || true

up: image connect-db
	docker run --rm -it \
		--network="$(MIGRATION_NETWORK)" \
		--volume="$(PWD)/migrations:/migrations" \
		"$(MIGRATOR_IMAGE)" \
		migrate -database $(DB_DSN) -source "file:///migrations" up

down: image connect-db
	docker run --rm \
		--network="$(MIGRATION_NETWORK)" \
		--volume="$(PWD)/migrations:/migrations" \
		"$(MIGRATOR_IMAGE)" \
		migrate -database $(DB_DSN) -source "file:///migrations" down

drop: image connect-db
	docker run --rm \
		--network="$(MIGRATION_NETWORK)" \
		--volume="$(PWD)/migrations:/migrations" \
		"$(MIGRATOR_IMAGE)" \
		migrate -database $(DB_DSN) -source "file:///migrations" drop

migrate: image connect-db
	docker run --rm \
	--network="$(MIGRATION_NETWORK)" \
	--volume="$(PWD)/migrations:/migrations" \
	"$(MIGRATOR_IMAGE)" \
	migrate -database $(DB_DSN) -source "file:///migrations" $(cmd)
