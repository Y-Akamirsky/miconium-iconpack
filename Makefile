# Miconium icon packs — installation
#
# Installs every pack in this repository into the system share directory
# ($(PREFIX)/share/miconium/<pack>), where Miconium picks it up automatically.
#
# Packs installed by this Makefile are SYSTEM-WIDE and independently
# updatable — they are versioned and shipped in a separate repository from the
# Miconium program itself.

DESTDIR  ?=
PREFIX   ?= /usr
SHAREDIR ?= $(PREFIX)/share/miconium

INSTALL ?= install
CP      ?= cp -a

# A directory at the repo root is a pack if it has both frames/ and signs/.
PACK_DETECT := for d in */; do d=$${d%/}; [ -d "$$d/frames" ] && [ -d "$$d/signs" ] && echo "$$d"; done
PACKS       := $(shell $(PACK_DETECT))

.PHONY: all validate install uninstall list clean

all: validate

# Validate the pack structure (needs only bash + coreutils).
validate:
	@./validate.sh

# List the packs this repository provides.
list:
	@$(PACK_DETECT)

install:
	@test -n "$(PACKS)" || { echo "no packs found in $$(pwd)" >&2; exit 1; }
	$(INSTALL) -dm755 $(DESTDIR)$(SHAREDIR)
	@for p in $(PACKS); do \
		echo "  installing pack: $$p"; \
		rm -rf "$(DESTDIR)$(SHAREDIR)/$$p"; \
		$(CP) "$$p" "$(DESTDIR)$(SHAREDIR)/"; \
		chmod -R a+rX "$(DESTDIR)$(SHAREDIR)/$$p"; \
	done

uninstall:
	@for p in $(PACKS); do \
		echo "  removing pack: $$p"; \
		rm -rf "$(DESTDIR)$(SHAREDIR)/$$p"; \
	done

clean:
	@: