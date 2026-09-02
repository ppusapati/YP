# Integration test harness for YieldPoint.
# Requires: Docker (or Podman), Go 1.25+.
#
# Usage:
#   make -C tests/integration ci      # full cycle: up, wait, test, down
#   make -C tests/integration test     # run tests (Postgres must be running)
#   make -C tests/integration up       # start Postgres
#   make -C tests/integration down     # stop and remove volumes

COMPOSE     := docker compose -f docker-compose.test.yml
DATABASE_URL := postgres://yieldpoint_test:yieldpoint_test@localhost:5433/yieldpoint_test?sslmode=disable

.PHONY: up down test ci wait-healthy

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down -v

wait-healthy:
	@echo "Waiting for Postgres to become healthy..."
	@for i in $$(seq 1 30); do \
		$(COMPOSE) ps --format '{{.Health}}' | grep -q healthy && break; \
		sleep 1; \
	done
	@$(COMPOSE) ps --format '{{.Health}}' | grep -q healthy || \
		(echo "Postgres did not become healthy in time"; exit 1)
	@echo "Postgres is healthy."

test:
	DATABASE_URL="$(DATABASE_URL)" \
		go test -tags=e2e -v -count=1 -timeout=5m ./...

ci: up wait-healthy test
	@$(MAKE) down
