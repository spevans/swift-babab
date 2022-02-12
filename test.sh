#!/bin/sh

MACOS_TESTS="Failed"
LINUX_5_2_TESTS="Failed"
LINUX_5_3_TESTS="Failed"
LINUX_5_4_TESTS="Failed"
LINUX_5_5_TESTS="Failed"
LINUX_LATEST_TESTS="Failed"
LINUX_NIGHTLY_TESTS="Failed"
NIGHTLY_TAG=swiftlang/swift:nightly-focal

docker pull ${NIGHTLY_TAG}
swift package clean
swift test && MACOS_TESTS="Passed"

docker run --rm -v `pwd`:/babab/5.2 -w /babab/5.2 -t swift:5.2 swift test --build-path=/tmp/.build && LINUX_5_2_TESTS="Passed"
docker run --rm -v `pwd`:/babab/5.3 -w /babab/5.3 -t swift:5.3 swift test --build-path=/tmp/.build && LINUX_5_3_TESTS="Passed"
docker run --rm -v `pwd`:/babab/5.4 -w /babab/5.4 -t swift:5.4 swift test --build-path=/tmp/.build && LINUX_5_4_TESTS="Passed"
docker run --rm -v `pwd`:/babab/5.5 -w /babab/5.5 -t swift:5.5 swift test --build-path=/tmp/.build && LINUX_5_5_TESTS="Passed"
docker run --rm -v `pwd`:/babab/latest -w /babab/latest -t swift:latest swift test --build-path=/tmp/.build && LINUX_LATEST_TESTS="Passed"
docker run --rm -v `pwd`:/babab/nightly -w /babab/nightly -t ${NIGHTLY_TAG} swift test --build-path=/tmp/.build && LINUX_NIGHTLY_TESTS="Passed"

echo
echo macOS tests ${MACOS_TESTS}
echo Linux-5.2 tests ${LINUX_5_2_TESTS}
echo Linux-5.3 tests ${LINUX_5_3_TESTS}
echo Linux-5.4 tests ${LINUX_5_4_TESTS}
echo Linux-5.5 tests ${LINUX_5_5_TESTS}
echo Linux latest tests ${LINUX_LATEST_TESTS}
echo Linux nightly tests ${LINUX_NIGHTLY_TESTS}
