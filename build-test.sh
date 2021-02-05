#!/usr/bin/env bash
pushd core && dart test test/test-runner.dart && popd
pushd api-sdk && dart test test/test-runner.dart && popd
pushd api && dart test test/test-runner.dart && popd
