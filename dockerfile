FROM alpine:latest

RUN apk add --no-cache bash

WORKDIR /app

#COPY the .sh files

#CMD [do the things]