FROM golang:1.17.13 AS builder

WORKDIR /golang

RUN mkdir cor_cmd_couchbase

COPY . ./cor_cmd_couchbase

RUN go version; \
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

EXPOSE 3015

RUN chmod +x main; \
    ls; \
    ls -la; \
    pwd;
RUN ls -la; \
    whoami;
CMD ["/go/src/app/main"]
