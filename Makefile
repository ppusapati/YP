.PHONY: all build test lint vet proto clean help

SERVICES := farm-service field-service crop-service sensor-service \
            irrigation-service soil-service yield-service \
            pest-prediction-service plant-diagnosis-service \
            satellite-service traceability-service commerce-service

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: lint vet test build ## Run lint, vet, test, build

build: ## Build all service binaries
	@for svc in $(SERVICES); do \
		echo "Building $$svc..."; \
		go build -trimpath ./$$svc/cmd/server || exit 1; \
	done

vet: ## Run go vet on all services and packages
	go vet ./packages/...
	@for svc in $(SERVICES); do \
		go vet ./$$svc/... || exit 1; \
	done

test: ## Run all tests
	go test -race -count=1 -timeout=5m ./packages/...
	@for svc in $(SERVICES); do \
		go test -race -count=1 -timeout=5m ./$$svc/... || exit 1; \
	done

test-packages: ## Run shared package tests only
	go test -race -count=1 -timeout=5m ./packages/...

lint: ## Run golangci-lint
	golangci-lint run --timeout=5m

proto: ## Regenerate protobuf code
	buf generate

proto-check: ## Check proto freshness
	buf generate
	@git diff --quiet -- '*.pb.go' '*.connect.go' || \
		(echo "Proto generated code is stale — run 'make proto' and commit" && exit 1)

clean: ## Remove build artifacts
	rm -f server
	@for svc in $(SERVICES); do \
		rm -f $$svc/cmd/server/server; \
	done

docker-%: ## Build Docker image for a service (e.g., make docker-farm-service)
	docker build --build-arg SERVICE=$* -t yieldpoint/$*:dev .
