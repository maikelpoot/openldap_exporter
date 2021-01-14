GITCOMMIT := $(shell git rev-parse --short HEAD 2>/dev/null)
BASE_DIR := ${CURDIR}
LDFLAGS := -X app/exporter.version=${GITCOMMIT}
GO_PATH := ${BASE_DIR}/code

precommit: clean format lint build

deps:
	cd ${GO_PATH}/src/app && CGO_ENABLED=0 GOPATH=${GO_PATH} dep ensure

clean:
	rm -rf target

target:
	mkdir target

format:
	GOPATH=${GO_PATH} go fmt app/exporter/...

lint:
	GOPATH=${GO_PATH} go vet app/exporter/...

compile = GOPATH=${GO_PATH} \
	GOOS=$1 GOARCH=amd64 CGO_ENABLED=0 \
	go build -v -ldflags "${LDFLAGS}" \
	-o target/openldap_exporter-$1 \
	app/exporter/cmd/openldap_exporter

build: target
	$(call compile,linux)
	$(call compile,darwin)

travis: clean deps
	$(call compile,linux)
