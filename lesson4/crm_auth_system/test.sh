#!/bin/bash
echo "🧪 Running CRM Auth System Tests..."

BASE_URL="http://localhost:3000"
PASS_COUNT=0
FAIL_COUNT=0

# Generate unique username for testing
TEST_USER="testuser_$(date +%s)"

# Test 1: Health check
echo -e "\n--- Test 1: Health Check ---"
HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
if [ "$HEALTH_RESPONSE" = "200" ]; then
    echo "✅ PASS: Service is responding"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: Service not responding (HTTP $HEALTH_RESPONSE)"
    ((FAIL_COUNT++))
fi

# Test 2: Register new user
echo -e "\n--- Test 2: User Registration ---"
REGISTER_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"username\": \"$TEST_USER\", \"password\": \"TestPassword123!\"}" \
    "$BASE_URL/register")
echo "Response: $REGISTER_RESPONSE"

if echo "$REGISTER_RESPONSE" | grep -q "User registered successfully"; then
    echo "✅ PASS: User registration successful"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: User registration failed"
    ((FAIL_COUNT++))
fi

# Test 3: Login
echo -e "\n--- Test 3: User Login ---"
LOGIN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"username\": \"$TEST_USER\", \"password\": \"TestPassword123!\"}" \
    "$BASE_URL/login")
echo "Response: $LOGIN_RESPONSE"

AUTH_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [ -n "$AUTH_TOKEN" ]; then
    echo "✅ PASS: Login successful, JWT received"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: Login failed, no JWT received"
    ((FAIL_COUNT++))
fi

# Test 4: Access protected route
echo -e "\n--- Test 4: Protected Route Access ---"
if [ -n "$AUTH_TOKEN" ]; then
    PROFILE_RESPONSE=$(curl -s -X GET -H "Authorization: Bearer $AUTH_TOKEN" "$BASE_URL/profile")
    echo "Response: $PROFILE_RESPONSE"
    
    if echo "$PROFILE_RESPONSE" | grep -q "Welcome to your profile"; then
        echo "✅ PASS: Protected route accessed successfully"
        ((PASS_COUNT++))
    else
        echo "❌ FAIL: Protected route access failed"
        ((FAIL_COUNT++))
    fi
else
    echo "⚠️ SKIP: No auth token available"
fi

# Test 5: Invalid credentials
echo -e "\n--- Test 5: Invalid Credentials ---"
INVALID_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"username": "nonexistent", "password": "wrongpass"}' \
    "$BASE_URL/login")
echo "Response: $INVALID_RESPONSE"

if echo "$INVALID_RESPONSE" | grep -q "Invalid credentials"; then
    echo "✅ PASS: Invalid credentials rejected correctly"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: Invalid credentials handling failed"
    ((FAIL_COUNT++))
fi

# Test 6: Duplicate registration
echo -e "\n--- Test 6: Duplicate Registration Prevention ---"
DUP_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"username\": \"$TEST_USER\", \"password\": \"AnotherPassword123!\"}" \
    "$BASE_URL/register")
echo "Response: $DUP_RESPONSE"

if echo "$DUP_RESPONSE" | grep -q "already exists"; then
    echo "✅ PASS: Duplicate registration prevented"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: Duplicate registration not prevented"
    ((FAIL_COUNT++))
fi

# Test 7: Missing credentials
echo -e "\n--- Test 7: Missing Credentials Validation ---"
MISSING_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"username": "someuser"}' \
    "$BASE_URL/register")
echo "Response: $MISSING_RESPONSE"

if echo "$MISSING_RESPONSE" | grep -q "required"; then
    echo "✅ PASS: Missing credentials rejected"
    ((PASS_COUNT++))
else
    echo "❌ FAIL: Missing credentials not validated"
    ((FAIL_COUNT++))
fi

# Summary
echo -e "\n========================================="
echo "TEST SUMMARY"
echo "========================================="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Total:  $((PASS_COUNT + FAIL_COUNT))"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "\n🎉 All tests passed!"
    exit 0
else
    echo -e "\n⚠️ Some tests failed!"
    exit 1
fi
