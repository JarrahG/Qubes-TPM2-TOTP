DIST ?= fc32
VERSION := $(shell cat version)
REL := $(shell cat rel)

SRC_FILE := tpm2-tools-$(VERSION).tar.gz

BUILDER_DIR ?= ../..
SRC_DIR ?= qubes-src

DISTFILES_MIRROR ?= https://github.com/tpm2-software/tpm2-totp/releases/download/$(VERSION)/
UNTRUSTED_SUFF := .UNTRUSTED
FETCH_CMD := wget --no-use-server-timestamps -q -O

SHELL := /bin/bash

%: %.sha512
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(DISTFILES_MIRROR)$@
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF).asc $(DISTFILES_MIRROR)$@.asc
	gpg2 --import keys/AndreasFuchsSIT.gpg keys/diabonas.gpg
	@gpg2 --verify $@$(UNTRUSTED_SUFF).asc || \
			{ echo "Wrong SHA512 checksum on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@sha512sum --status -c <(printf "$$(cat $<)  -\n") <$@$(UNTRUSTED_SUFF) || \
			{ echo "Wrong SHA512 checksum on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

.PHONY: get-sources
get-sources: $(SRC_FILE)

.PHONY: verify-sources
verify-sources:
	@true

