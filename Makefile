.PHONY: all build test lint vet proto clean help api-docs new-service setup

# Every service with a main package, discovered rather than listed.
#
# The list written here by hand named fifteen of thirty-one, so `make build`
# built half the platform and `make test` ran half the tests — and both printed
# a clean run. A service is a directory with cmd/server in it; there is no
# second place for that to be true.
SERVICES := $(sort $(patsubst %/cmd/server,%,$(wildcard *-service/cmd/server)))

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: lint vet test build ## Run lint, vet, test, build

build: ## Build all service binaries
	@for svc in $(SERVICES); do \
		echo "Building $$svc..."; \
		go build -trimpath ./$$svc/cmd/server || exit 1; \
	done

# packages/ is its own Go module, so `./packages/...` from the root matches
# nothing the root module owns and the command fails with "main module does not
# contain package" — which is what these targets did. -C runs in that module.
vet: ## Run go vet on all services and packages
	go vet ./...
	go vet -C packages ./...

test: ## Run all tests
	go test -race -count=1 -timeout=10m ./...
	$(MAKE) test-packages

test-packages: ## Run shared package tests only
	go test -C packages -race -count=1 -timeout=5m ./...

lint: ## Run golangci-lint
	golangci-lint run --timeout=5m

tools: ## Install pinned protoc-gen-* tools from tools.go
	go install connectrpc.com/connect/cmd/protoc-gen-connect-go
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go install google.golang.org/protobuf/cmd/protoc-gen-go

proto: ## Regenerate Go protobuf code (run 'make tools' first)
	buf generate

# All three run from the repository root. Both generator templates resolve
# their `out` and `inputs` against the working directory, so running them from
# anywhere else writes to the wrong place — which is exactly what the previous
# `cd` in proto-mobile did, silently.
proto-web: ## Regenerate TypeScript proto types
	bash web/packages/proto/generate.sh

proto-mobile: ## Regenerate Dart proto types
	buf generate --template mobile/packages/flutter_proto/buf.gen.yaml

proto-all: proto proto-web proto-mobile ## Regenerate all proto code (Go + TS + Dart)

proto-check: ## Check proto freshness (CI gate)
	buf generate
	@./scripts/check-generated-drift.sh "run 'make proto' and commit" '*.pb.go' '*.connect.go'

clean: ## Remove build artifacts
	rm -f server
	@for svc in $(SERVICES); do \
		rm -f $$svc/cmd/server/server; \
	done

api-docs: ## Regenerate OpenAPI specs from proto definitions
	./scripts/generate-api-docs.sh

new-service: ## Scaffold a new Go microservice (e.g., make new-service NAME=weather)
	@test -n "$(NAME)" || (echo "Usage: make new-service NAME=<name>" && exit 1)
	./scripts/new-service.sh $(NAME)

setup: ## Install pre-commit hooks and dev dependencies
	@echo "Installing pre-commit hooks..."
	pre-commit install
	@echo "Installing Go tools..."
	$(MAKE) tools
	@echo "Downloading Go modules..."
	go mod download
	@echo "Setup complete."

docker-%: ## Build Docker image for a service (e.g., make docker-farm-service)
	docker build --build-arg SERVICE=$* -t yieldpoint/$*:dev .

mockserver: ## Run the offline stand-in for external APIs (Open-Meteo, OpenWeather, PlantNet, Vision)
	go run ./cmd/mockserver -v

storage-lifecycle: ## Apply object-storage tiering and expiry rules (use DRY_RUN=1 to preview)
	@if [ -n "$(DRY_RUN)" ]; then \
		./scripts/storage-lifecycle.sh --dry-run; \
	else \
		./scripts/storage-lifecycle.sh; \
	fi
