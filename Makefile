all: build

TARGET=ping_exporter
SOURCES = $(filter-out target_test.go, $(wildcard *.go))

build: $(SOURCES)
	@echo "Building $(TARGET) ..."
	@go build -o $(TARGET) $(SOURCES)

debian: build
	@if [ -z ${VERSION} ]; then \
		echo "VERSION needs to be provided as VERSION=x.y.z in the command line."; \
		exit 1; \
	fi 
	@echo "Building debian package for version=$(VERSION)"
	@mkdir -p debian/ping_exporter-${VERSION}_amd64/usr/bin/
	@mkdir -p debian/ping_exporter-${VERSION}_amd64/DEBIAN/
	@mkdir -p debian/ping_exporter-${VERSION}_amd64/etc/ping_exporter/
	@mkdir -p debian/ping_exporter-${VERSION}_amd64/etc/init.d/
	@cp ping_exporter debian/ping_exporter-${VERSION}_amd64/usr/bin/
	@cp config-sample.yaml debian/ping_exporter-${VERSION}_amd64/etc/ping_exporter/config.yaml
	@cp scripts/ping-exporter debian/ping_exporter-${VERSION}_amd64/etc/init.d/
	@sed 's/VERSION/${VERSION}/g' META > debian/ping_exporter-${VERSION}_amd64/DEBIAN/control
	@cd debian/ && dpkg-deb --build --root-owner-group ping_exporter-${VERSION}_amd64/ && cd -
	@if [ -f debian/ping_exporter-${VERSION}_amd64.deb ]; then \
		echo "Build successful."; \
	else \
		echo "Build failed."; \
	fi \

clean:
	@echo "Cleaning up ..."
	@rm -f $(TARGET)



