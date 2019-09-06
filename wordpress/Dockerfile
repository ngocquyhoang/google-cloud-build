FROM alpine:3.10.2

MAINTAINER Hoang Ngoc Quy <ngocquyhoang3112@gmail.com>

RUN apk update \
	&& apk upgrade \
	&& apk add --no-cache rsync openssh-client \
	&& rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /script/docker-entrypoint.sh

WORKDIR /app/deploy

ENTRYPOINT ["/bin/sh", "/script/docker-entrypoint.sh"]

CMD ["deploy"]
