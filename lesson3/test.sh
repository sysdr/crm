#!/bin/bash

# --- CRM Database Test Script ---
# This script tests the PostgreSQL database setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Define variables
DB_CONTAINER_NAME="crm-postgres"
DB_USER="crmuser"
DB_PASSWORD="crmpassword"
DB_NAME="crm_db"
DB_PORT="5432"

# Use Docker from Windows if in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    DOCKER="/mnt/c/Program Files/Docker/Docker/resources/bin/docker.exe"
else
    DOCKER="docker"
fi

echo "==================================================="
echo " Running CRM Database Tests (Day 3)"
echo "==================================================="

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Container is running
echo ""
echo "Test 1: Container Status"
if "$DOCKER" ps --format '{{.Names}}' | grep -q "^${DB_CONTAINER_NAME}$"; then
    echo "  PASSED - Container '$DB_CONTAINER_NAME' is running"
    ((TESTS_PASSED++))
else
    echo "  FAILED - Container '$DB_CONTAINER_NAME' is not running"
    ((TESTS_FAILED++))
    echo "Please run ./setup.sh first"
    exit 1
fi

# Test 2: Database connection
echo ""
echo "Test 2: Database Connection"
if "$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "SELECT 1;" &> /dev/null; then
    echo "  PASSED - Database connection successful"
    ((TESTS_PASSED++))
else
    echo "  FAILED - Cannot connect to database"
    ((TESTS_FAILED++))
fi

# Test 3: Users table exists
echo ""
echo "Test 3: Users Table Exists"
TABLE_CHECK=$("$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name='users';")
if [ "$(echo $TABLE_CHECK | tr -d ' ')" -eq "1" ]; then
    echo "  PASSED - Table 'users' exists"
    ((TESTS_PASSED++))
else
    echo "  FAILED - Table 'users' does not exist"
    ((TESTS_FAILED++))
fi

# Test 4: Sample user exists
echo ""
echo "Test 4: Sample User Exists"
USER_COUNT=$("$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM users WHERE email='alice@example.com';")
if [ "$(echo $USER_COUNT | tr -d ' ')" -ge "1" ]; then
    echo "  PASSED - Sample user 'alice@example.com' exists"
    ((TESTS_PASSED++))
else
    echo "  FAILED - Sample user not found"
    ((TESTS_FAILED++))
fi

# Test 5: Insert a test user
echo ""
echo "Test 5: Insert Test User"
"$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME <<EOF
INSERT INTO users (email, password_hash)
VALUES ('test-user-$(date +%s)@example.com', 'test_hash')
ON CONFLICT (email) DO NOTHING;
EOF
if [ $? -eq 0 ]; then
    echo "  PASSED - Test user inserted successfully"
    ((TESTS_PASSED++))
else
    echo "  FAILED - Could not insert test user"
    ((TESTS_FAILED++))
fi

# Test 6: Verify data is not zero/empty
echo ""
echo "Test 6: Verify Data (Non-Zero Values)"
TOTAL_USERS=$("$DOCKER" exec -i $DB_CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM users;")
TOTAL_USERS=$(echo $TOTAL_USERS | tr -d ' ')
if [ "$TOTAL_USERS" -gt 0 ]; then
    echo "  PASSED - Database has $TOTAL_USERS user(s)"
    ((TESTS_PASSED++))
else
    echo "  FAILED - Database has no users (zero)"
    ((TESTS_FAILED++))
fi

# Summary
echo ""
echo "==================================================="
echo " Test Summary: ${TESTS_PASSED} passed, ${TESTS_FAILED} failed"
echo "==================================================="

if [ $TESTS_FAILED -eq 0 ]; then
    echo " All tests passed!"
    exit 0
else
    echo " Some tests failed"
    exit 1
fi
