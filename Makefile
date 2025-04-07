PAK_NAME := $(shell jq -r .label config.json)
PAK_TYPE := $(shell jq -r .pak_type config.json)
PAK_FOLDER := $(shell echo $(PAK_TYPE) | tr '[:lower:]' '[:upper:]' | cut -c1)$(shell echo $(PAK_TYPE) | cut -c2-)s

PUSH_SDCARD_PATH ?= /mnt/SDCARD
PUSH_PLATFORM ?= tg5040

ARCHITECTURES := arm arm64
PLATFORMS := rg35xxplus tg5040

DROPBEAR_VERSION ?= 0.1.0
JQ_VERSION ?= 1.7.1
MINUI_LIST_VERSION := 0.10.1
MINUI_PRESENTER_VERSION := 0.7.0

clean:
	rm -f bin/*/jq || true
	rm -f bin/*/dropbear || true
	rm -f bin/*/minui-list || true
	rm -f bin/*/minui-presenter || true

build: $(foreach platform,$(PLATFORMS),bin/$(platform)/minui-list bin/$(platform)/minui-presenter) $(foreach arch,$(ARCHITECTURES),bin/$(arch)/dropbear bin/$(arch)/jq)

bin/arm/jq:
	mkdir -p bin/arm
	curl -f -o bin/arm/jq -sSL https://github.com/jqlang/jq/releases/download/jq-$(JQ_VERSION)/jq-linux-armhf
	curl -sSL -o bin/arm/jq.LICENSE "https://raw.githubusercontent.com/jqlang/jq/refs/heads/$(JQ_VERSION)/COPYING"

bin/arm64/jq:
	mkdir -p bin/arm64
	curl -f -o bin/arm64/jq -sSL https://github.com/jqlang/jq/releases/download/jq-$(JQ_VERSION)/jq-linux-arm64
	curl -sSL -o bin/arm64/jq.LICENSE "https://raw.githubusercontent.com/jqlang/jq/refs/heads/$(JQ_VERSION)/COPYING"

# also creates dbclient, dropbearkey, dropbearconvert, and scp
bin/%/dropbear:
	mkdir -p bin/$*
	curl -f -o bin/$*/dropbear -sSL "https://github.com/josegonzalez/compiled-dropbear/releases/download/$(DROPBEAR_VERSION)/dropbear-$*"
	curl -sSL -o bin/$*/dropbear.LICENSE "https://raw.githubusercontent.com/mkj/dropbear/refs/heads/master/LICENSE"
	chmod +x bin/$*/dropbear

bin/%/minui-list:
	mkdir -p bin/$*
	curl -f -o bin/$*/minui-list -sSL https://github.com/josegonzalez/minui-list/releases/download/$(MINUI_LIST_VERSION)/minui-list-$*
	chmod +x bin/$*/minui-list

bin/%/minui-presenter:
	mkdir -p bin/$*
	curl -f -o bin/$*/minui-presenter -sSL https://github.com/josegonzalez/minui-presenter/releases/download/$(MINUI_PRESENTER_VERSION)/minui-presenter-$*
	chmod +x bin/$*/minui-presenter

release: build
	mkdir -p dist
	git archive --format=zip --output "dist/$(PAK_NAME).pak.zip" HEAD
	while IFS= read -r file; do zip -r "dist/$(PAK_NAME).pak.zip" "$$file"; done < .gitarchiveinclude
	ls -lah dist

push: release
	rm -rf "dist/$(PAK_NAME).pak"
	cd dist && unzip "$(PAK_NAME).pak.zip" -d "$(PAK_NAME).pak"
	adb push "dist/$(PAK_NAME).pak/." "$(PUSH_SDCARD_PATH)/$(PAK_FOLDER)/$(PUSH_PLATFORM)/$(PAK_NAME).pak"
