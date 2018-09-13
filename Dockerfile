# FROM alpine
# # RUN apt-get update && apt-get install -y curl && \
# #   curl -L https://packagecloud.io/golang-migrate/migrate/gpgkey | apt-key add - && \
# #   echo "deb https://packagecloud.io/golang-migrate/migrate/ubuntu/ xenial main" > \
# #   /etc/apt/sources.list.d/migrate.list && \
# #   apt-get update && \
# #   apt-get install -y migrate
# COPY ./bin/migrate ./migrate
# CMD ["sleep", "9999999"]
FROM golang
RUN go get -u -d github.com/lib/pq
RUN go get -u -d github.com/golang-migrate/migrate/cli/
RUN cd $GOPATH/src/github.com/golang-migrate/migrate/cli
RUN go build -tags 'postgres' -o /go/bin/migrate github.com/golang-migrate/migrate/cli
