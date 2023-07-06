.PHONY: all clean extra
ARCH := $(shell uname -m)
WORKSPACE_DIR := $(shell pwd)
REPO_ROOT := $(WORKSPACE_DIR)/.repo
REPO_DIR := $(REPO_ROOT)/$(ARCH)
PACMAN_CONF := $(REPO_ROOT)/pacman-$(ARCH).conf
RUN_MAKEPKG := makepkg --syncdeps --noconfirm --force 

OVOS_PACKAGES := $(notdir $(wildcard PKGBUILDs/*))
EXTRA_PACKAGES := $(notdir $(wildcard PKGBUILDs-extra/*))
ALL_PACKAGES := $(OVOS_PACKAGES) + $(EXTRA_PACKAGES)

# The default target will build all OVOS packages and only those 'extra' dependent packages which are in use
all: $(OVOS_PACKAGES)

extra: $(EXTRA_PACKAGES)

clean: rebuild
	@rm -rf ./{PKGBUILDs,PKGBUILDs-extra}/*/{pkg,src}
rebuild:
	@echo 'Deleted any built packages, you may now run make all'
	@rm -rf ./{PKGBUILDs,PKGBUILDs-extra}/*/*.pkg.tar* $(REPO_DIR)

uninstall:
	@pacman -Qq | sort | comm -12 - <(echo "$(ALL_PACKAGES)" | tr ' ' '\n' | sort) | xargs sudo pacman -Rcns --noconfirm

repo:
	@mkdir -p "$(REPO_DIR)/"
	@printf "[ovos]\nSigLevel = Optional TrustAll\nServer = file:///$(REPO_DIR)" > $(PACMAN_CONF)

%.pkg.tar.zst:
	$(eval DIR := $(shell echo '$*' | cut -d* -f1))
	$(eval PKG := $(shell basename $(DIR)))
	@echo 'Building $(PKG)'
	@cd $(DIR) \
		&& $(RUN_MAKEPKG) \
		&& cp "$(PKG)"*.pkg.tar.zst $(REPO_DIR) \
		&& repo-add "$(REPO_DIR)/ovos.db.tar.gz" "$(REPO_DIR)/$(PKG)"*.pkg.tar.zst \
		&& sudo pacman -Syy --config $(PACMAN_CONF) 

