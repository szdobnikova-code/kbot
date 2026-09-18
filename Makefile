APP=kbot
REGISTRY=ghcr.io
REPOSITORY=szdobnikova-code/kbot

VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

TARGETOS=linux
TARGETARCH=amd64

IMAGE=${REGISTRY}/${REPOSITORY}:${VERSION}-${TARGETOS}-${TARGETARCH}

format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v

build: format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X=github.com/szdobnikova-code/kbot/cmd.appVersion=${VERSION}"

linux:
	$(MAKE) build TARGETOS=linux TARGETARCH=amd64

arm:
	$(MAKE) build TARGETOS=linux TARGETARCH=arm64

macos:
	$(MAKE) build TARGETOS=darwin TARGETARCH=arm64

windows:
	$(MAKE) build TARGETOS=windows TARGETARCH=amd64

image:
	docker build \
		--build-arg TARGETOS=${TARGETOS} \
		--build-arg TARGETARCH=${TARGETARCH} \
		--build-arg VERSION=${VERSION} \
		-t ${IMAGE} .
push:
	docker push ${IMAGE}

clean:
	rm -f kbot
	docker rmi ${IMAGE} || true
