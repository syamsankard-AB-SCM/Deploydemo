FROM golang:1.17.7 AS builder

WORKDIR /golang

RUN mkdir cor_cmd_couchbase

COPY . ./cor_cmd_couchbase

RUN go version ; \
    cd cor_cmd_couchbase; \
    go env -w GO111MODULE=auto;  \
    git config --global --add url."https://REIMS-Admin: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@github.com/".insteadOf "https://github.com/"; \
    go env -w GOPRIVATE="github.com/tcs-chennai/tatacliq-backend";  \
    go env -w GOFLAGS=-mod=vendor;  \
    go mod tidy;  \
    go mod vendor;  \
    go build -o main . ;

FROM ubuntu:latest

WORKDIR /go/src/app

COPY --from=builder /golang/cor_cmd_couchbase/main .

RUN chmod +x main

EXPOSE 3015

CMD ["./main"]
