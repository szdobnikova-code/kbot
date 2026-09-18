FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS builder

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG VERSION=dev

WORKDIR /go/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    go build -v \
    -o kbot \
    -ldflags "-X=github.com/szdobnikova-code/kbot/cmd.appVersion=${VERSION}"

FROM alpine:3.22

RUN apk add --no-cache ca-certificates

WORKDIR /

COPY --from=builder /go/src/app/kbot /kbot

ENTRYPOINT ["/kbot"]
