APP=${shell basename $(shell git remote get-url origin)}
REGISTRY=szdobnikova91
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #linux darwin windows
TARGETARCH=arm64 #amd64

format:
	gofmt -s -w ./

get:
	go get	

lint:
	golint 

test:
	go test -v		

build: format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X"=github.com/szdobnikova-code/kbot/cmd.appVersion=${VERSION}

image:
	docker build -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} .

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot	