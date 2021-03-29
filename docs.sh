#!/bin/sh
jazzy --clean --author "Simon Evans" --author_url https://github.com/spevans --github_url https://github.com/spevans/swift-babab --module BABAB --output docs 
rm -r docs/docsets
