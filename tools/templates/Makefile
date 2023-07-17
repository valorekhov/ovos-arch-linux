.PHONY: all clean extra repo aur-repo rebuild uninstall
MODE := "DirectInstall"
ARCH := $(shell uname -m)
WORKSPACE_DIR := $(shell pwd)
REPO_ROOT := $(WORKSPACE_DIR)/.repo
REPO_DIR := $(REPO_ROOT)/$(ARCH)
PACMAN_CONF := $(REPO_ROOT)/pacman-$(ARCH).conf

define post_build_repo
	$(eval PKG := $(shell basename $(1)))
	@cd $(1) \
		&& cp "$(PKG)"*.pkg.tar.zst $(REPO_DIR) \
		&& repo-add "$(REPO_DIR)/ovos.db.tar.gz" "$(REPO_DIR)/$(PKG)"*.pkg.tar.zst \
		&& sudo pacman -Syy --config $(PACMAN_CONF) 
	@echo "#####  Package successfully built and added to the repo: $(1)"
endef

define post_build_single_pkg
	@echo "#####  Package successfully built: $(1)"
endef

ifeq ($(MODE), "Repo")
	RUN_MAKEPKG := makepkg --syncdeps --noconfirm --force
	RUN_POST_PKG_BUILD := post_build_repo
else 
	RUN_MAKEPKG := makepkg -srif --noconfirm 
	RUN_POST_PKG_BUILD := post_build_single_pkg
endif

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

repo: aur-repo
	@mkdir -p "$(REPO_DIR)/"
	@printf "[ovos]\nSigLevel = Optional TrustAll\nServer = file:///$(REPO_DIR)" > $(PACMAN_CONF)

aur-repo:
	@mkdir -p "$(WORKSPACE_DIR)/AUR"
	./tools/aur-repo.sh "$(WORKSPACE_DIR)/AUR/" "$(WORKSPACE_DIR)/aur.lock"

%.pkg.tar.zst:
	$(eval DIR := $(shell echo '$*' | cut -d* -f1))
	@echo '##### Building $(DIR) with $(RUN_MAKEPKG)'
	@cd $(DIR) && $(RUN_MAKEPKG) 
	$(call $(RUN_POST_PKG_BUILD),$(DIR))
