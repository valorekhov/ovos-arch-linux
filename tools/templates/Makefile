.PHONY: all clean extra repo aur-repo rebuild uninstall
# MODE := "source"
ARCH := $(shell uname -m)
WORKSPACE_DIR := $(shell pwd)
REPO_ROOT := $(WORKSPACE_DIR)/.repo
REPO_DIR := $(REPO_ROOT)/$(ARCH)
PACMAN_CONF := $(REPO_ROOT)/pacman-$(ARCH).conf

ifeq ($(MODE), repo)
	RUN_MAKEPKG := "$(WORKSPACE_DIR)/tools/pkg-build/repo-build.sh" "$(REPO_DIR)" "$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh"
else 
	RUN_MAKEPKG := "$(WORKSPACE_DIR)/tools/pkg-build/source-build.sh"
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
	@cp /etc/pacman.conf "$(PACMAN_CONF)"
	@printf "\n\n[ovos-arch]\nSigLevel = Optional TrustAll\nServer = file:///$(REPO_DIR)" >> $(PACMAN_CONF)
	@cp "$(WORKSPACE_DIR)/tools/pkg-build/pacman-wrapper.sh" "$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh"
	@sed -i 's|/etc/pacman.conf|$(PACMAN_CONF)|g' "$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh"
	@chmod +x "$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh"
ifeq (, $(wildcard $(REPO_DIR)/ovos-arch.db.tar.gz))
	@repo-add "$(REPO_DIR)/ovos-arch.db.tar.gz"
	@echo "Repo created..."
endif

sync-repo:
	@"$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh" -Syy 

aur-repo:
	@mkdir -p "$(WORKSPACE_DIR)/AUR"
	./tools/aur-repo.sh "$(WORKSPACE_DIR)/AUR/" "$(WORKSPACE_DIR)/aur.lock"

%.pkg.tar.zst:
	$(eval DIR := $(shell echo '$*' | cut -d* -f1))
	@echo "Building $(DIR) with ''$(RUN_MAKEPKG)''"
	@cd $(DIR) && $(RUN_MAKEPKG)
	