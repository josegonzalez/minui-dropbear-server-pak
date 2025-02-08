TAG ?= DROPBEAR_2024.86
BUILD_DATE := "$(shell date -u +%FT%TZ)"
PAK_NAME := $(shell jq -r .label config.json)

PLATFORMS := tg5040 rg35xxplus
MINUI_LIST_VERSION := 0.3.1
MINUI_KEYBOARD_VERSION := 0.2.1

clean:
	rm -f bin/dropbear || true
	rm -f bin/minui-keyboard-* || true
	rm -f bin/minui-list-* || true
	rm -f bin/sdl2imgshow || true
	rm -f res/fonts/BPreplayBold.otf || true

build: $(foreach platform,$(PLATFORMS),bin/minui-keyboard-$(platform) bin/minui-list-$(platform)) bin/dropbear bin/sdl2imgshow res/fonts/BPreplayBold.otf

bin/dropbear:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbear bin/dropbear
	docker container rm extract
	chmod +x bin/dropbear

bin/dbclient:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dbclient bin/dbclient
	docker container rm extract
	chmod +x bin/dbclient

bin/dropbearkey:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbearkey bin/dropbearkey
	docker container rm extract
	chmod +x bin/dropbearkey

bin/dropbearconvert:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/dropbearconvert bin/dropbearconvert
	docker container rm extract
	chmod +x bin/dropbearconvert

bin/minui-keyboard-%:
	curl -f -o bin/minui-keyboard-$* -sSL https://github.com/josegonzalez/minui-keyboard/releases/download/$(MINUI_KEYBOARD_VERSION)/minui-keyboard-$*
	chmod +x bin/minui-keyboard-$*

bin/minui-list-%:
	curl -f -o bin/minui-list-$* -sSL https://github.com/josegonzalez/minui-list/releases/download/$(MINUI_LIST_VERSION)/minui-list-$*
	chmod +x bin/minui-list-$*

bin/scp:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.dropbear --progress plain -t app/dropbear:$(TAG) .
	docker container create --name extract app/dropbear:$(TAG)
	docker container cp extract:/go/src/github.com/mkj/dropbear/scp bin/scp
	docker container rm extract
	chmod +x bin/scp

bin/sdl2imgshow:
	docker buildx build --platform linux/arm64 --load -f Dockerfile.sdl2imgshow --progress plain -t app/sdl2imgshow:$(TAG) .
	docker container create --name extract app/sdl2imgshow:$(TAG)
	docker container cp extract:/go/src/github.com/kloptops/sdl2imgshow/build/sdl2imgshow bin/sdl2imgshow
	docker container rm extract
	chmod +x bin/sdl2imgshow

res/fonts/BPreplayBold.otf:
	curl -sSL -o res/fonts/BPreplayBold.otf "https://raw.githubusercontent.com/shauninman/MinUI/refs/heads/main/skeleton/SYSTEM/res/BPreplayBold-unhinted.otf"

release: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist
