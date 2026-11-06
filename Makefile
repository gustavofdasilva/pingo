include .env
export

run: 
	go run cmd/pingo/main.go

test:
	go test ./...

lint:
	golangci-lint run

build:
	go build -ldflags="-s -w" -o bin/pingo ./cmd/pingo