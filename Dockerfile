FROM golang
RUN go get -u -d github.com/lib/pq
RUN go get -u -d github.com/golang-migrate/migrate/cli/
RUN cd $GOPATH/src/github.com/golang-migrate/migrate/cli
RUN go build -tags 'postgres' -o /go/bin/migrate github.com/golang-migrate/migrate/cli
