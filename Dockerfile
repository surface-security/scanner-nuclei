FROM golang:alpine3.15 AS builder

ARG BIN_VERSION=2.5.7
ARG GO_MOD=github.com/surface-security/scanner-nuclei

WORKDIR /go/src/${GO_MOD}

ADD go.mod .
ADD go.sum .
RUN go mod download
ADD . . 
RUN go build -v -ldflags="-s -w" -o "nuclei" cmd/nuclei/nuclei.go
RUN ["./nuclei", "-ut"]

FROM alpine:latest

ARG GO_MOD=github.com/surface-security/scanner-nuclei

COPY --from=builder /go/src/${GO_MOD}/nuclei /nuclei
COPY ppbtemplates /root/nuclei-templates/ppb

VOLUME /input
VOLUME /output

ENTRYPOINT ["/nuclei"]
