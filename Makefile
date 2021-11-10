PRODUCT_NAME := LottiePlayer

.PHONY: build
build: ## LottiePlayer をビルドします。
	./scripts/build.sh

.PHONY: bootstrap
bootstrap: ## 必要なツールをセットアップします。プロジェクトを最初に始めるときに実行してください。
	@make install-brew
	@make bootstrap-mint

.PHONY: open
open: ## xcodeproj をオープンします。
	open ./${PRODUCT_NAME}.xcodeproj

.PHONY: clear-cache
clear-cache: ## ビルド時に生成された中間ファイルを削除します。
	rm -rf ${HOME}/Library/Developer/Xcode/DerivedData/*

.PHONY: exec-swiftlint
exec-swiftlint: ## swiftlint を実行します。
	./Mint/bin/swiftlint

.PHONY: exec-swiftformat
exec-swiftformat: ## swiftformat を実行します。
	$(eval SWIFT_VERSION := $(shell swift --version | tr ' ' '\n' | head -n 4 | tail -n 1))
	./Mint/bin/swiftformat "./LottiePlayer/" --swiftversion $(SWIFT_VERSION)


.PHONY: install-brew
install-brew: ## brew で管理するツールを導入します。
	brew list mint &>/dev/null || brew install mint
	brew link --force mint

.PHONY: bootstrap-mint
bootstrap-mint: ## Mint で管理するツールを導入します。
	mkdir -p Mint/{lib,bin}
	MINT_PATH=./Mint/lib MINT_LINK_PATH=./Mint/bin mint bootstrap --link

.PHONY: help
.DEFAULT_GOAL := help
help: ## Display this help screen.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
