TAG ?= 2024.86

clean:
	rm -f bin/dropbear || true

build: bin/evtest
	true

bin/evtest:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.evtest --progress plain -t app/evtest:$(TAG) .
	docker container create --name extract app/evtest:$(TAG)
	docker container cp extract:/go/src/github.com/freedesktop/evtest/evtest bin/evtest
	docker container rm extract
	chmod +x bin/evtest
