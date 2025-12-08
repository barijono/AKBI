#!/bin/bash
#
# Git Exposure Remediation Verification Script
# ASPI Red Team - Security Assessment
#
# This script verifies that .git directory exposure has been properly remediated
#
# Usage: ./remediation_verifier.sh <target_url>
# Example: ./remediation_verifier.sh https://apidevportal.aspi-indonesia.or.id

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if target URL provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No target URL provided${NC}"
    echo "Usage: $0 <target_url>"
    echo "Example: $0 https://apidevportal.aspi-indonesia.or.id"
    exit 1
fi

TARGET="$1"
PASSED=0
FAILED=0
WARNINGS=0

# Banner
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      GIT EXPOSURE REMEDIATION VERIFICATION TOOL              ║${NC}"
echo -e "${BLUE}║      ASPI Red Team Security Assessment                       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Target:${NC} $TARGET"
echo -e "${BLUE}Date:${NC}   $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Function to test URL
test_url() {
    local url="$1"
    local description="$2"
    local expected_code="$3"

    echo -n "Testing: $description ... "

    # Make HTTP request
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10)

    if [ "$HTTP_CODE" == "$expected_code" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $HTTP_CODE)"
        PASSED=$((PASSED + 1))
        return 0
    elif [ "$HTTP_CODE" == "403" ]; then
        echo -e "${YELLOW}⚠ WARNING${NC} (HTTP $HTTP_CODE - Forbidden)"
        echo "  → .git directory may still exist but is blocked"
        WARNINGS=$((WARNINGS + 1))
        return 1
    elif [ "$HTTP_CODE" == "200" ]; then
        echo -e "${RED}✗ FAIL${NC} (HTTP $HTTP_CODE - Still Accessible!)"
        FAILED=$((FAILED + 1))
        return 2
    else
        echo -e "${GREEN}✓ PASS${NC} (HTTP $HTTP_CODE - Not accessible)"
        PASSED=$((PASSED + 1))
        return 0
    fi
}

echo "═══════════════════════════════════════════════════════════════"
echo " TEST 1: Critical .git Files"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Test critical files
test_url "$TARGET/.git/HEAD" ".git/HEAD" "404"
test_url "$TARGET/.git/config" ".git/config" "404"
test_url "$TARGET/.git/index" ".git/index" "404"
test_url "$TARGET/.git/description" ".git/description" "404"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " TEST 2: Git Logs and References"
echo "═══════════════════════════════════════════════════════════════"
echo ""

test_url "$TARGET/.git/logs/HEAD" ".git/logs/HEAD" "404"
test_url "$TARGET/.git/refs/heads/main" ".git/refs/heads/main" "404"
test_url "$TARGET/.git/refs/heads/master" ".git/refs/heads/master" "404"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " TEST 3: Other Sensitive Files"
echo "═══════════════════════════════════════════════════════════════"
echo ""

test_url "$TARGET/.env" ".env file" "404"
test_url "$TARGET/.git" ".git directory" "404"
test_url "$TARGET/.gitignore" ".gitignore" "404"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " TEST 4: Security Headers"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check security headers
echo -n "Checking security headers ... "
HEADERS=$(curl -s -I "$TARGET")

# Check for important security headers
HAS_HSTS=0
HAS_CSP=0
HAS_XCTO=0
SERVER_VERSION=0

if echo "$HEADERS" | grep -i "Strict-Transport-Security" > /dev/null; then
    HAS_HSTS=1
fi

if echo "$HEADERS" | grep -i "Content-Security-Policy" > /dev/null; then
    HAS_CSP=1
fi

if echo "$HEADERS" | grep -i "X-Content-Type-Options" > /dev/null; then
    HAS_XCTO=1
fi

if echo "$HEADERS" | grep -i "Server: nginx/\|Server: Apache/" > /dev/null; then
    SERVER_VERSION=1
fi

echo ""
echo "  Security Headers Status:"
if [ $HAS_HSTS -eq 1 ]; then
    echo -e "    ${GREEN}✓${NC} HSTS (Strict-Transport-Security)"
else
    echo -e "    ${YELLOW}⚠${NC} HSTS header missing"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $HAS_CSP -eq 1 ]; then
    echo -e "    ${GREEN}✓${NC} CSP (Content-Security-Policy)"
else
    echo -e "    ${YELLOW}⚠${NC} CSP header missing"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $HAS_XCTO -eq 1 ]; then
    echo -e "    ${GREEN}✓${NC} X-Content-Type-Options"
else
    echo -e "    ${YELLOW}⚠${NC} X-Content-Type-Options header missing"
    WARNINGS=$((WARNINGS + 1))
fi

if [ $SERVER_VERSION -eq 1 ]; then
    echo -e "    ${YELLOW}⚠${NC} Server version disclosed in headers"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "    ${GREEN}✓${NC} Server version not disclosed"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " VERIFICATION RESULTS"
echo "═══════════════════════════════════════════════════════════════"
echo ""

TOTAL=$((PASSED + FAILED + WARNINGS))

echo -e "  Tests Passed:    ${GREEN}$PASSED${NC}"
echo -e "  Tests Failed:    ${RED}$FAILED${NC}"
echo -e "  Warnings:        ${YELLOW}$WARNINGS${NC}"
echo -e "  Total Tests:     $TOTAL"
echo ""

# Overall assessment
if [ $FAILED -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ REMEDIATION VERIFIED - ALL TESTS PASSED                   ║${NC}"
    echo -e "${GREEN}║  .git directory exposure has been properly fixed             ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    exit 0
elif [ $FAILED -eq 0 ]; then
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  ⚠ REMEDIATION VERIFIED - WITH WARNINGS                      ║${NC}"
    echo -e "${YELLOW}║  .git files are blocked but improvements recommended         ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Recommendations:${NC}"
    echo "  • Review and remove .git directory from server"
    echo "  • Implement missing security headers"
    echo "  • Remove server version disclosure"
    exit 0
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ REMEDIATION FAILED - CRITICAL ISSUES FOUND                ║${NC}"
    echo -e "${RED}║  .git directory is still accessible!                         ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}IMMEDIATE ACTIONS REQUIRED:${NC}"
    echo "  1. Block .git directory in web server configuration:"
    echo "     nginx: location ~ /\.git { deny all; return 404; }"
    echo "     apache: RedirectMatch 404 /\.git"
    echo "  2. Remove .git directory from production: rm -rf /var/www/.git"
    echo "  3. Restart web server"
    echo "  4. Run this verification script again"
    exit 1
fi
