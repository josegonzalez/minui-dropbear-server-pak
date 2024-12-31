TAG ?= DROPBEAR_2024.86

clean:
	rm -f bin/evtest || true
	rm -f bin/dropbear || true

build: bin/evtest bin/dropbear

bin/evtest:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.evtest --progress plain -t app/evtest:$(TAG) .
	docker container create --name extract app/evtest:$(TAG)
	docker container cp extract:/go/src/github.com/freedesktop/evtest/evtest bin/evtest
	docker container rm extract
	chmod +x bin/evtest

bin/dropbear:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbear bin/dropbear
	docker container rm extract
	chmod +x bin/dropbear

bin/dbclient:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dbclient bin/dbclient
	docker container rm extract
	chmod +x bin/dbclient

bin/dropbearkey:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbearkey bin/dropbearkey
	docker container rm extract
	chmod +x bin/dropbearkey

bin/dropbearconvert:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbearconvert bin/dropbearconvert
	docker container rm extract
	chmod +x bin/dropbearconvert

bin/scp:
	docker build --build-arg BUILD_DATE=$(BUILD_DATE) -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/scp bin/scp
	docker container rm extract
	chmod +x bin/scp
