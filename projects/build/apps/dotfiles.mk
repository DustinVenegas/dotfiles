# dotfiles.mk - Uses dotfiles.sh to manage dotfiles
# 
# Configuration:
#   DFFLAGS: Global flags for dotfiles.sh. 
#
# Description:
#   Force with DFFLAGS. For example to force status and health:
#       DFFLAGS=--force make dotfiles/status dotfiles/health
DFFLAGS?=
DFBIN = ./dotfiles.sh $(DFFLAGS)

NOT_SKIP_VALID=grep -v 'SKIP VALID' | grep -v 'WRITE VALID'
DFFLAG_WRITE=-W
DFFLAG_FORCE=--force

dotfiles: dotfiles/status

dotfiles/configure:
	@$(DFBIN) $(DFFLAG_WRITE)

dotfiles/health: FAILM_1=dotfiles/health failed: outdated symlinks:
dotfiles/health: FAILM_2=Resolve outdated symlinks with 'make dotfiles/configure', 'DFFLAGS=--force make dotfiles/status', 'DFFLAGS=--force make dotfiles/configure'
dotfiles/health: FAILM_3=Force overrides with 'DFFLAGS=--force make dotfiles/status', 'DFFLAGS=--force make dotfiles/configure'
dotfiles/health:
	@STATUS="$$($(DFBIN) | ( $(NOT_SKIP_VALID) || true ))"; if [ "$$STATUS" ]; then echo '$(FAILM_1)'; echo "$$STATUS"; echo "$(FAILM_2)"; echo "$(FAILM_3)"; exit 1; fi

dotfiles/status:
	@$(DFBIN)

.PHONY: dotfiles dotfiles/health dotfiles/status dotfiles/configure

HEALTH_DEPS+=dotfiles/health
CONFIGURE_DEPS+=dotfiles/configure
