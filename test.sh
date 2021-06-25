#!/bin/sh

MACOS_TESTS="Passed"
LINUX_TESTS="Passed"
LINUX_5_2_TESTS="Passed"

swift package clean
swift test || MACOS_TESTS="Failed"

docker build -f Dockerfile-5.2 --build-arg CACHEBUST=$(date +%s) --tag=swift-babab-tests-5-2:$(date +%s) . || LINUX_5_2_TESTS="Failed"
docker build -f Dockerfile --build-arg CACHEBUST2=$(date +%s) --tag=swift-babab-tests:$(date +%s) . || LINUX_TESTS="Failed"

echo
echo macOS tests ${MACOS_TESTS}
echo Linux-5.2 tests ${LINUX_5_2_TESTS}
echo Linux tests ${LINUX_TESTS}
