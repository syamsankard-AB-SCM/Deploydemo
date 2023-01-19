FROM registry.access.redhat.com/openshift3/ose-docker-builder:v3.11.705-1.g7a17a5d AS builder
WORKDIR /golang
RUN mkdir cor_cmd_couchbase
COPY . ./cor_cmd_couchbase
RUN curl -fsSLo https://go.dev/dl/go1.17.7.linux-amd64.tar.gz
RUN mkdir -p bin;
RUN tar -C /golang -xzf go1.17.7.linux-amd64.tar.gz;
RUN rm go1.17.7.linux-amd64.tar.gz;
RUN export PATH="/golang/go/bin";
RUN go version;
RUN cd cor_cmd_couchbase;
RUN go env -w GO111MODULE=auto;
RUN git config --global --add url."https://REIMS-Admin:${GPT}@github.com/".insteadOf "https://github.com/";
RUN go env -w GOPRIVATE="github.com/tcs-chennai/tatacliq-backend";
RUN go env -w GOFLAGS=-mod=vendor;
RUN go mod tidy;
RUN go mod vendor;
RUN go build -o main . ;

FROM registry.access.redhat.com/ubi8/ubi-micro:latest
WORKDIR /go/src/app
COPY --from=builder /golang/cor_cmd_couchbase/main .
RUN chmod +x main
EXPOSE 3015
CMD ["./main"]
