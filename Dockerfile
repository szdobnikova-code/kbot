FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.26 AS builder

WORKDIR /go/src/app
COPY . .
RUN make get
RUN make build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT [ "./kbot" ]
