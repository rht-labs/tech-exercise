FROM node:16.14-alpine

RUN apk add --no-cache tini && npm install -g docsify-cli@4.4.3

COPY . /docs
WORKDIR /docs
EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD [ "docsify", "serve",  "-p", "8080", "/docs/docs/" ]
