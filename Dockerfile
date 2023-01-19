FROM golang:1.17.9 As builder
WORKDIR /go
RUN mkdir cor_cmd_couchbase
COPY . ./cor_cmd_couchbase
RUN go version;
RUN cd cor_cmd_couchbase;
RUN go env -w GO111MODULE=auto;
#RUN git config --global --add url."https://REIMS-Admin:${GPT}@github.com/".insteadOf "https://github.com/"; 
RUN go env -w GOPRIVATE="github.com/syamsankard-AB-SCM/tatacliq-backend";
RUN go env -w GOFLAGS=-mod=vendor;
#RUN go mod tidy;
#RUN go mod vendor;
RUN go build -o main . ;

FROM alpine:3.13
WORKDIR /go/src/app
COPY --from=builder /go/cor_cmd_couchbase/main .
RUN chmod +x main
EXPOSE 3015
CMD ["./main"]
