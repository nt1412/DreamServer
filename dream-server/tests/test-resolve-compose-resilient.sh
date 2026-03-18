#!/bin/bash
# ============================================================================
# Resolve compose stack resilient parsing test
# ============================================================================
# Tests that resolve-compose-stack.sh continues when encountering bad manifests
#
# Usage: ./tests/test-resolve-compose-resilient.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

pass() { echo -e "  ${GREEN}✓ PASS${NC} $1"; PASSED=$((PASSED + 1)); }
fail() { echo -e "  ${RED}✗ FAIL${NC} $1"; FAILED=$((FAILED + 1)); }

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║   Resolve Compose Resilient Parsing Test      ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# 1. Exception handler uses continue instead of sys.exit(1)
if grep -A4 "except Exception as e:" "$ROOT_DIR/scripts/resolve-compose-stack.sh" | grep -q "continue"; then
    pass "Exception handler uses continue (not sys.exit)"
else
    fail "Exception handler still uses sys.exit(1)"
fi

# 2. Error message is still printed to stderr
if grep -A3 "except Exception as e:" "$ROOT_DIR/scripts/resolve-compose-stack.sh" | grep -q "print.*stderr"; then
    pass "Error message printed to stderr"
else
    fail "Error message not printed to stderr"
fi

# 3. Manifest path is included in error message
if grep -A3 "except Exception as e:" "$ROOT_DIR/scripts/resolve-compose-stack.sh" | grep -q "Manifest path"; then
    pass "Manifest path included in error"
else
    fail "Manifest path missing from error"
fi

# 4. Helpful message about skipping service
if grep -A3 "except Exception as e:" "$ROOT_DIR/scripts/resolve-compose-stack.sh" | grep -q "will be skipped"; then
    pass "Skip message present"
else
    fail "Skip message missing"
fi

echo ""
echo "Result: $PASSED passed, $FAILED failed"
[[ $FAILED -eq 0 ]]
