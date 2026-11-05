run: 
	go run cmd/pingo/main.go

test:
	go test ./...

lint:
	golangci-lint run