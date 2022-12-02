#!/usr/bin/env bash

set -euo pipefail

pushd gosrc
go test -bench=. | tee README.txt
popd
