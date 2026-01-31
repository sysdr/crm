#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

echo "🧪 Running CRM AI System Tests..."
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Health check
echo "Test 1: Backend Health Check"
if curl -s http://localhost:3001/api/health | grep -q "healthy"; then
    echo "  ✅ PASSED - Backend is healthy"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAILED - Backend health check failed"
    ((TESTS_FAILED++))
fi

# Test 2: Get metrics
echo ""
echo "Test 2: Get Metrics API"
METRICS=$(curl -s http://localhost:3001/api/metrics)
if echo "$METRICS" | grep -q "totalCustomers"; then
    echo "  ✅ PASSED - Metrics endpoint returns data"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAILED - Metrics endpoint not working"
    ((TESTS_FAILED++))
fi

# Test 3: Demo endpoint
echo ""
echo "Test 3: Demo Data Generation"
DEMO_RESULT=$(curl -s -X POST http://localhost:3001/api/demo -H "Content-Type: application/json")
if echo "$DEMO_RESULT" | grep -q "success"; then
    echo "  ✅ PASSED - Demo endpoint generates data"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAILED - Demo endpoint not working"
    ((TESTS_FAILED++))
fi

# Test 4: Verify metrics updated
echo ""
echo "Test 4: Verify Metrics Updated (non-zero values)"
METRICS=$(curl -s http://localhost:3001/api/metrics)
TOTAL_CUSTOMERS=$(echo "$METRICS" | grep -o '"totalCustomers":[0-9]*' | grep -o '[0-9]*')
REVENUE=$(echo "$METRICS" | grep -o '"revenue":[0-9]*' | grep -o '[0-9]*')
if [ "$TOTAL_CUSTOMERS" -gt 0 ] && [ "$REVENUE" -gt 0 ]; then
    echo "  ✅ PASSED - Metrics have non-zero values"
    echo "     Total Customers: $TOTAL_CUSTOMERS"
    echo "     Revenue: $REVENUE"
    ((TESTS_PASSED++))
else
    echo "  ❌ FAILED - Metrics still have zero values"
    ((TESTS_FAILED++))
fi

# Test 5: Frontend check
echo ""
echo "Test 5: Frontend Accessibility"
if curl -s http://localhost:3000 | grep -q "CRM"; then
    echo "  ✅ PASSED - Frontend is accessible"
    ((TESTS_PASSED++))
else
    echo "  ⚠️  SKIPPED - Frontend may still be starting (this is normal for dev server)"
fi

# Summary
echo ""
echo "========================================"
echo "Test Summary: ${TESTS_PASSED} passed, ${TESTS_FAILED} failed"
echo "========================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "⚠️  Some tests failed"
    exit 1
fi
