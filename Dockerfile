# Run using: docker build --tag=swift-babab-tests:$(date +%s) .
FROM swift:latest

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && apt-get -q install -y libsqlite3-dev

COPY . /root/
WORKDIR /root
RUN swift test 
