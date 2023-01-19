  FROM
      registry.access.redhat.com/openshift3/ose-docker-builder:v3.11.705-1.g7a17a5d
      AS builder

      WORKDIR /golang

      RUN mkdir cor_cmd_couchbase

      COPY . ./cor_cmd_couchbase

      RUN curl -fsSLo /tmp/go.tgz https://go.dev/dl/go1.17.7.linux-amd64.tar.gz;
      \
        mkdir -p bin; \
        tar -C /golang -xzf /tmp/go.tgz; \
        rm /tmp/go.tgz; \
        export PATH="/golang/go/bin:${PATH}"; \
        go version ; \

        cd cor_cmd_couchbase; \

        go env -w GO111MODULE=auto;  \

        git config --global --add url."https://REIMS-Admin:${GPT}@github.com/".insteadOf "https://github.com/"; \

        go env -w GOPRIVATE="github.com/tcs-chennai/tatacliq-backend";  \

        go env -w GOFLAGS=-mod=vendor;  \

        go mod tidy;  \

        go mod vendor;  \

        go build -o main . ;


      FROM registry.access.redhat.com/ubi8/ubi-micro:latest

      WORKDIR /go/src/app

      COPY --from=builder /golang/cor_cmd_couchbase/main .

      RUN chmod +x main

      EXPOSE 3015

      CMD ["./main"]
    git:
      uri: 'git@github.com:tcs-chennai/tatacliq-backend.git'
      ref: master
    contextDir: scm/golang/core_msvc/command/cor_cmd_couchbase
    sourceSecret:
      name: github-auth
  triggers:
    - type: ConfigChange
  runPolicy: Serial
