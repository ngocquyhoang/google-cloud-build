FROM composer:1.9.0

MAINTAINER Hoang Ngoc Quy <ngocquyhoang3112@gmail.com>

RUN apk update \
	&& apk upgrade \
	&& apk add --no-cache rsync openssh-client \
	&& rm -rf /var/cache/apk/*

COPY docker-entrypoint.sh /script/docker-entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/bin/sh", "/script/docker-entrypoint.sh"]

CMD ["deploy"]
