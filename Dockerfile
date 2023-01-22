FROM golang:1.17-alpine

WORKDIR /app

RUN go version

RUN go clean -modcache

RUN go get golang.org/x/net/html

RUN go mod tidy -compat=1.17

RUN go mod download all

RUN go mod init

#RUN go mod download

COPY *.go ./

RUN go build -o /cor_cmd_couchbase

EXPOSE 9090
EXPOSE 8080

CMD [ "/cor_cmd_couchbase" ]
