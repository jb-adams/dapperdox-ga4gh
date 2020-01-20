FROM golang:latest

WORKDIR /usr/src/app
ENV GOPATH=/usr/src/app
ENV GOBIN=/usr/src/app/bin
ENV PATH="${GOBIN}:${PATH}"

RUN apt-get update \
    && apt-get install --yes build-essential

COPY assets ./assets
COPY openapi ./openapi
COPY scripts ./scripts

RUN mkdir bin
RUN git clone https://github.com/DapperDox/dapperdox.git

RUN cd dapperdox; go get && go build
EXPOSE 7575

CMD ["dapperdox", "-spec-dir=openapi", "-spec-filename=/refget.yaml", "-spec-filename=/rnaget.yaml", "-spec-filename=/htsget.yaml", "-assets-dir=assets", "-theme-dir=assets/themes", "-theme=dapperdox-theme-ga4gh", "-bind-addr=0.0.0.0:7575"]
