FROM golang:1.17.7 AS builder

WORKDIR /golang

RUN mkdir cor_cmd_couchbase

COPY . ./cor_cmd_couchbase

RUN go version; 
RUN cd cor_cmd_couchbase; 
RUN go env -w GO111MODULE=auto;  
#RUN git config --global --add url."https://REIMS-Admin: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@github.com/".insteadOf "https://github.com/"; 
RUN go env -w GOPRIVATE="github.com/syamsankard-AB-SCM/tatacliq-backend";  
RUN go env -w GOFLAGS=-mod=vendor;  
RUN go mod tidy;  
RUN go mod vendor;  
RUN go build -o main . ;
    
FROM ubuntu:latest

WORKDIR /go/src/app

COPY --from=builder /golang/cor_cmd_couchbase/main .

RUN chmod +x main

EXPOSE 3015

CMD ["./main"]
