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

.PHONY: get-sources
get-sources: $(SRC_FILE)

.PHONY: import-keys
import-keys:
	@if [ -n "$$GNUPGHOME" ]; then rm -f "$$GNUPGHOME/tpm2-totp-trustedkeys.gpg"; fi
	@gpg --no-auto-check-trustdb --no-default-keyring --keyring tpm2-totp-trustedkeys.gpg -q --import keys/*.gpg

.PHONY: verify-sources
verify-sources: import-keys
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF) $(DISTFILES_MIRROR)$@
	@$(FETCH_CMD) $@$(UNTRUSTED_SUFF).asc $(DISTFILES_MIRROR)$@.asc
	@gpg2 --keyring tpm2-totp-trustedkeys.gpg --verify $@$(UNTRUSTED_SUFF).asc || \
			{ echo "Bad GPG signature on on $@$(UNTRUSTED_SUFF)!"; exit 1; }
	@mv $@$(UNTRUSTED_SUFF) $@

