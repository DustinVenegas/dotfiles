#!/bin/zsh

# Comprehensive test script for zsh startup configurations
# Tests all combinations of startup modes to ensure .zshrc consistency

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results tracking
PASS_COUNT=0
FAIL_COUNT=0
RESULTS=()

# Normalize output flag (for automation)
NORMALIZE_OUTPUT=0

# Parse script flags (currently only -n)
while getopts ":n" opt; do
  case "$opt" in
    n)
      NORMALIZE_OUTPUT=1
      ;;
  esac
done

shift $((OPTIND-1))

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Zsh Configuration Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to run a test
run_test() {
    local name="$1"
    shift  # Remove name, rest are flags
    
    echo -n "Testing: $name ... "
    
    # Run zsh with test command that exits cleanly
    if output=$(zsh "$@" -c 'exit 0' 2>&1); then
        echo -e "${GREEN}✓ PASS${NC}"
        RESULTS+=("$name: PASS")
        ((PASS_COUNT++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        RESULTS+=("$name: FAIL")
        if [[ -n "$output" ]]; then
            if [[ $NORMALIZE_OUTPUT -eq 1 ]]; then
                # Emit GCC-style diagnostics for problem matchers
                # Using an existing workspace file to anchor problems
                local anchor_file="xdg/zsh-vme/interactive.sh"
                echo "$output" | while IFS= read -r line; do
                    if [[ "$line" == *warning* ]]; then
                        echo "$anchor_file:1:1: warning: $line"
                    else
                        echo "$anchor_file:1:1: error: $line"
                    fi
                done
            else
                echo "  Error output:"
                echo "$output" | sed 's/^/    /'
            fi
        fi
        ((FAIL_COUNT++))
        return 1
    fi
}

# Test 1: Fresh mode (no config files)
run_test "Fresh (zsh -f)" -f

# Test 2: Fresh + Interactive
run_test "Fresh + Interactive (zsh -f -i)" -f -i

# Test 3: Normal Interactive (most common)
run_test "Normal Interactive (zsh -i)" -i

# Test 4: Login shell
run_test "Login Shell (zsh -l)" -l

# Test 5: Login + Interactive
run_test "Login + Interactive (zsh -l -i)" -l -i

# Test 6: Non-Interactive batch mode
run_test "Non-Interactive (zsh)"

# Test 7: Command mode (one-liner)
run_test "Command Mode (zsh -c 'command')"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Results Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

for result in "${RESULTS[@]}"; do
    if [[ "$result" == *"PASS"* ]]; then
        echo -e "${GREEN}✓${NC} $result"
    else
        echo -e "${RED}✗${NC} $result"
    fi
done

echo ""
echo "Total: ${GREEN}$PASS_COUNT passed${NC}, ${RED}$FAIL_COUNT failed${NC}"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "\n${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed. Review the errors above.${NC}"
    exit 1
fi
