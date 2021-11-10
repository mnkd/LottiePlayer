#!/bin/sh
set -ex

# fetch tags
git fetch --tags

# generate release notes
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%s %h"
