#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RSENV_TEST_DIR"
  cd "$RSENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${RSENV_ROOT}/version" ]
  run rsenv-version-origin
  assert_success "${RSENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$RSENV_ROOT"
  touch "${RSENV_ROOT}/version"
  run rsenv-version-origin
  assert_success "${RSENV_ROOT}/version"
}

@test "detects RSENV_VERSION" {
  RSENV_VERSION=1 run rsenv-version-origin
  assert_success "RSENV_VERSION environment variable"
}

@test "detects local file" {
  touch .rust-version
  run rsenv-version-origin
  assert_success "${PWD}/.rust-version"
}

@test "detects alternate version file" {
  touch .rsenv-version
  run rsenv-version-origin
  assert_success "${PWD}/.rsenv-version"
}
