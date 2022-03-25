FROM node:16.14-alpine

RUN apk add --no-cache tini && npm install -g docsify-cli@latest

COPY . /docs
WORKDIR /docs
EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--"]
CMD [ "docsify", "start",  "-p", "8080", "./" ]
