APPLICATION := "Gitea Redux"
APP_ID	 := $(shell replicated api get /v3/apps | jq -r --arg slug ${REPLICATED_APP} '.apps[] | select ( .slug == $$slug ) | .id')
SEQUENCE ?= $(shell replicated api get /v3/app/$(APP_ID)/releases | jq '.releases[0].sequence')

PROJECT_DIR		 := $(shell pwd)
PROJECT_PARAMS := secrets/params.yaml
CHANNEL				 ?= $(shell git branch --show-current)

RELEASE_DIR := $(PROJECT_DIR)/release

VERSION	:= $(shell yq .version Chart.yaml)
PACKAGE	:= $(RELEASE_DIR)/gitea-$(VERSION).tgz

KOTS_DIR       := $(PROJECT_DIR)/kots
KOTS_MANIFESTS := $(wildcard $(KOTS_DIR)/*.yaml)

app:
	@replicated app create $(APPLICATION)

chart: $(PACKAGE)

$(PACKAGE): Chart.yaml Chart.lock templates/*
	@helm package -u . -d $(RELEASE_DIR)

kots: $(KOTS_MANIFESTS) $(PACKAGE) 

.PHONY: $(KOTS_MANIFESTS)
$(KOTS_MANIFESTS):
	@cp $@ $(RELEASE_DIR)

lint: chart
	@replicated release lint --chart $(PACKAGE)

kots-lint: kots
	@replicated release lint --yaml-dir $(RELEASE_DIR)

release: chart
ifndef RELEASE_NOTES
	$(error RELEASE_NOTES not provided)
endif
	replicated release create \
		--app ${REPLICATED_APP} \
		--chart ${PACKAGE} \
		--version $(VERSION) \
		--release-notes "$(RELEASE_NOTES)" \
		--ensure-channel \
		--promote $(CHANNEL)

kots-release: kots
ifndef RELEASE_NOTES
	$(error RELEASE_NOTES not provided)
endif
	replicated release create \
		--app ${REPLICATED_APP} \
		--yaml-dir $(RELEASE_DIR) \
		--version $(VERSION) \
		--release-notes "$(RELEASE_NOTES)" \
		--ensure-channel \
		--promote $(CHANNEL)

unstable: 
ifndef RELEASE_NOTES
	$(error RELEASE_NOTES not provided)
endif
	@replicated release promote $(SEQUENCE) Unstable \
		--version $(VERSION) \
		--release-notes "$(RELEASE_NOTES)"

beta: 
ifndef RELEASE_NOTES
	$(error RELEASE_NOTES not provided)
endif
	@replicated release promote $(SEQUENCE) Beta \
		--version $(VERSION) \
		--release-notes "$(RELEASE_NOTES)"

stable: 
ifndef RELEASE_NOTES
	$(error RELEASE_NOTES not provided)
endif
	@replicated release promote $(SEQUENCE) Stable \
		--version $(VERSION) \
		--release-notes "$(RELEASE_NOTES)"

license:
	@replicated customer download-license --customer Schowalter > schowalter.yaml

customers:
	@replicated customer create --channel Stable --expires-in 730h --name Klein-Stehr
	@replicated customer create --channel Stable --expires-in 17530h --name "Purdy Inc."
	@replicated customer create --channel Stable --snapshot --expires-in 8766h --name Treutel
	@replicated customer create --channel Stable --snapshot --expires-in 17530h --name "Casper Group"
	@replicated customer create --channel Beta --snapshot --expires-in 8766h --name Will-Kautzer
	@replicated customer create --channel Stable --snapshot --name Sipes-Erdman
	@replicated customer create --channel Stable --snapshot --expires-in 730h --name "Little and Sons"
	@replicated customer create --channel Stable --snapshot --expires-in 26300h --name "Ferry Group"
	@replicated customer create --channel Stable --snapshot --expires-in 2160h --name Bergstrom
	@replicated customer create --channel Beta --snapshot --expires-in 8766h --name "Schamberger, LLC"
	@replicated customer create --channel Stable --snapshot --expires-in 8766h --name Trantow-Carroll
	@replicated customer create --channel Stable --snapshot --expires-in 8766h --name "Swaniawski, Inc."
	@replicated customer create --channel Stable --snapshot --expires-in 8766h --name "Silver Fir"
	@replicated customer create --channel Stable --snapshot --expires-in 8766h --name Trueyx
	@replicated customer create --channel Unstable --snapshot --expires-in 8766h --name Schowalter
	@replicated customer create --channel Stable --expires-in 26300h --name Halvorsen
	@replicated customer create --channel Beta --snapshot --expires-in 730h --name Spinka
	@replicated customer create --channel Beta --snapshot --expires-in 17530h --name Stehr
	@replicated customer create --channel Unstable --kots-install=false --expires-in 8766h --name Nienow
	@replicated customer create --channel Beta --expires-in 17530h --name Quitzon-Greenholt
	@replicated customer create --channel Stable --snapshot --expires-in 8766h --name Emmerich
	@replicated customer create --channel Stable --snapshot --name Gulgow
	@replicated customer create --channel Beta --expires-in 730h --name Vandervort
	@replicated customer create --channel Stable --snapshot --expires-in 26300h --name Langworth

