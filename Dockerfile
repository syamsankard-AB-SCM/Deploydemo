FROM golang:1.17

RUN mkdir -p /app

COPY go.mod go.sum /app/

WORKDIR /app

RUN go mod download

COPY . .

RUN go mod tidy -compat=1.17

RUN go build -o main .

CMD ["./main"]
