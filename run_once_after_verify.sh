#!/bin/sh
# run_once_after_verify.sh - Post-apply verification hook.
#
# chezmoi executes scripts whose names begin with "run_once_after_" exactly
# once, after all managed files have been applied.  This script uses mise to
# verify the managed tool environment when mise is available, and exits
# gracefully when it is not.
#
# See https://www.chezmoi.io/reference/scripts/ for chezmoi script details.
# See https://mise.jdx.dev/ for mise documentation.

set -e

if command -v mise >/dev/null 2>&1; then
    echo "chezmoi post-apply: running mise doctor..."
    mise doctor || echo "WARN: mise doctor reported issues — review the output above"
else
    echo "chezmoi post-apply: mise not found, skipping verification"
fi
