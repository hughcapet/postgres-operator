#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

arch=$(dpkg --print-architecture)

set -ex

# Install dependencies

apt-get update
apt-get install -y wget

(
    cd /tmp
    wget -q "https://storage.googleapis.com/golang/go1.18.9.linux-${arch}.tar.gz" -O go.tar.gz
    tar -xf go.tar.gz
    mv go /usr/local
    ln -s /usr/local/go/bin/go /usr/bin/go
    go version
)

# Build

export PATH="$PATH:$HOME/go/bin"
export GOPATH="$HOME/go"
mkdir -p docker/build/
echo '{\n "url": "git:$(GITURL)",\n "revision": "$(GITHEAD)",\n "author": "$(USER)",\n "status": "$(GITSTATUS)"\n}' > scm-source.json
cp scm-source.json docker/build/

GO111MODULE=on go mod vendor
CGO_ENABLED=0 go build -o build/postgres-operator -v -ldflags "-X=main.version=e1fbdd9" cmd/main.go
