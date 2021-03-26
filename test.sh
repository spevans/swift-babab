#!/bin/sh

MACOS_TESTS="Passed"
LINUX_TESTS="Passed"

swift package clean
swift test || MACOS_TESTS="Failed"
docker build --tag=swift-babab-tests:$(date +%s) . || LINUX_TESTS="Failed"

echo
echo macOS tests ${MACOS_TESTS}
echo Linux tests ${LINUX_TESTS}
