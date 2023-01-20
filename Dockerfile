FROM golang:1.17-alpine3.13 AS builder
WORKDIR /golang
RUN mkdir cor_cmd_couchbase
COPY . ./cor_cmd_couchbase
#RUN export PATH="/golang/go/bin";
RUN cd cor_cmd_couchbase;
RUN go env -w GO111MODULE=auto;
#RUN git config --global --add url."https://REIMS-Admin:${GPT}@github.com/".insteadOf "https://github.com/";
#RUN go env -w GOPRIVATE="github.com/syamoliam/tatacliq-backend";
RUN go env -w GOFLAGS=-mod=vendor;
#RUN go mod download;
#RUN go mod tidy;
#RUN go mod vendor;
RUN CGO=ENABLED=0 GOOS=linux go build -o main main.go;

FROM alpine:3.13
WORKDIR /go/src/app
COPY --from=builder /golang/cor_cmd_couchbase/main .
RUN chmod +x main
EXPOSE 3015
CMD ["./main"]
