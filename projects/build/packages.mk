OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')
DISTRO=$(shell cat /etc/os-release 2>&1 | grep '^ID=' | cut -d= -f2 | tr -d '"')
TO_LOWER=$(shell echo '$1' | tr '[:upper:]' '[:lower:]')
TO_UPPER=$(shell echo '$1' | tr '[:lower:]' '[:upper:]')

BASEVERBS=check install upgrade

NOPM=no-packagemanager-detected
NOPMCFG=
NOPMVERBS=$(BASEVERBS)
NOPMFLAGS_CHECK=echo 'Config Error: No Package Manager Configured' && exit 101
NOPMFLAGS_INSTALL=echo 'Config Error: No Package Manager Configured' && exit 101
NOPMFLAGS_UPGRADE=echo 'Config Error: No Package Manager Configured' && exit 101

BREW=brew
BREWCFG=packages/$(OS)-$(PKGMGR)
BREWVERBS=$(BASEVERBS) # dump
BREWFLAGS_CHECK=bundle check -v --no-upgrade --file=$(PKGMGRCFG)
BREWFLAGS_INSTALL=bundle install -v --no-upgrade --file=$(PKGMGRCFG)
BREWFLAGS_UPGRADE=bundle install -v --file=$(PKGMGRCFG)
# BREWFLAGS_DUMP=bundle list --all --file=$(IDK)

APT=apt
APTCFG=packages/$(OS)-$(DISTRO)-$(APT)
APTVERBS=$(BASEVERBS)
APTFLAGS_CHECK=list --installed $(shell cat $(PKGMGRCFG) | tr '\n' ' ' 2>/dev/null || echo '')
APTFLAGS_INSTALL=install -y $(shell cat $(PKGMGRCFG) | tr '\n' ' ' 2>/dev/null || echo '')
APTFLAGS_UPGRADE=upgrade -y $(shell cat $(PKGMGRCFG) | tr '\n' ' ' 2>/dev/null || echo '')

APK=apk
APKCFG=packages/$(OS)-$(DISTRO)-$(APK)
APKVERBS=$(BASEVERBS)
APKFLAGS_CHECK=info $(shell cat $(PKGMGRCFG) | tr '\n' ' ' 2>/dev/null || echo '')
APKFLAGS_INSTALL=add --no-cache $(shell cat $(PKGMGRCFG) | tr '\n' ' ' 2>/dev/null || echo '')
APKFLAGS_UPGRADE=upgrade $(shell cat $(PKGMGRCFG) | tr '\n' ' ' 2>/dev/null || echo '')

# Default Package Manager
PKGMGR=
ifeq ($(OS),darwin)
PKGMGR=$(BREW)
else ifeq ($(DISTRO),ubuntu)
PKGMGR=$(APT)
else ifeq ($(DISTRO),alpine)
PKGMGR=$(APK)
else
$(warning PKGMGR Unspecified: Unrecognized $(OS) Distribution: $(DISTRO))
endif

PKGMGRCFG=$($(call TO_UPPER,$(PKGMGR)CFG))
PKGMGRVERBS=$($(call TO_UPPER,$(PKGMGR)VERBS))
PKGMGRFLAGS_NAME=$(call TO_UPPER,$(PKGMGR)FLAGS_$1)
PKGMGRFLAGS_VAL=$($(PKGMGRFLAGS_NAME))

$(if $(PKGMGR),,$(warning PKGMGR Unspecified: No Package Manager Found))
$(if $(PKGMGRCFG),,$(warning PKGMGRCFG Unspecified: No Package Manager Config Found))
$(if $(call PKGMGRFLAGS_VAL,CHECK),,$(warning PKGMGR_P_CHECK Unspecified: No Package Manager Check Parameters Found))
$(if $(call PKGMGRFLAGS_VAL,INSTALL),,$(warning PKGMGR_P_INSTALL Unspecified: No Package Manager Install Parameters Found))
$(if $(call PKGMGRFLAGS_VAL,UPGRADE),,$(warning PKGMGR_P_UPGRADE Unspecified: No Package Manager Upgrade Parameters Found))

$(foreach verb,$(PKGMGRVERBS),$(if $(call PKGMGRFLAGS_VAL,$(verb)),,$(warning Packages Parameter Unspecified: Missing value for: $(call PKGMGRFLAGS_NAME,$(verb)))))

packages/health:
	$(info PKGMGR: $(PKGMGR))
	$(info PKGMGRCFG: $(PKGMGRCFG))
	$(info PKGMGRVERBS: $(PKGMGRVERBS))
	$(info ---)
	$(foreach verb,$(PKGMGRVERBS),$(info $(call PKGMGRFLAGS_NAME,$(verb))=$(call PKGMGRFLAGS_VAL,$(verb))))

ABC:=$(BUILD_DIR)/packages-$(OS)-$(PKGMGR)-%.log
$(ABC): $(PKGMGRCFG)
	@$(call CMDFAILTEE,$(PKGMGR) $(call PKGMGRFLAGS_VAL,$*),$@.tmp)

CMDFAIL2=exec 4>&1; RET=$$( ( ( $1 3>&-; echo $$? 1>&3; ) 4>&- | $2 1>&4; ) 3>&1 ); exec 4>&-; exit $$RET
CMDFAILTEE=$(call CMDFAIL2,$1,tee $2)

# Package Management Targets
packages/check: $(PKGMGRCFG)
	@echo "Checking packages with $(PKGMGR)..."
	@$(PKGMGR) $(call PKGMGRFLAGS_VAL,CHECK)

packages/install: $(PKGMGRCFG)
	@echo "Installing packages with $(PKGMGR)..."
	@$(PKGMGR) $(call PKGMGRFLAGS_VAL,INSTALL)

packages/upgrade: $(PKGMGRCFG)
	@echo "Upgrading packages with $(PKGMGR)..."
	@$(PKGMGR) $(call PKGMGRFLAGS_VAL,UPGRADE)

packages/configure: packages/install

# Package Testing
packages/test:
	@echo "Testing package manager $(PKGMGR)..."
	@test -n "$(PKGMGR)" || (echo "ERROR: No package manager detected"; exit 1)
	@test -f "$(PKGMGRCFG)" || (echo "ERROR: Package config file not found: $(PKGMGRCFG)"; exit 1)
	@$(PKGMGR) --version >/dev/null 2>&1 || (echo "ERROR: Package manager $(PKGMGR) not working"; exit 1)
	@echo "Package manager $(PKGMGR) test passed"

.PHONY: packages/check packages/install packages/upgrade packages/configure packages/health packages/test

# Legacy targets for compatibility
packages: packages/configure

# Add to global dependencies
CONFIGURE_DEPS+=packages/configure
TEST_DEPS+=packages/test 