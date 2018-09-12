FROM alpine:3.7
COPY migrations ./migrations
COPY ./Makefile ./Makefile
COPY ./main ./main
ENTRYPOINT [ "./main", "-path", "migrations/", "-kind", "up" ]
