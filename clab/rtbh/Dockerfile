FROM golang:1.21

RUN mkdir /otg
WORKDIR /otg

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

CMD ["tail","-f","/dev/null"]