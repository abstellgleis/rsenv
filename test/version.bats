#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${RSENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RSENV_TEST_DIR"
  cd "$RSENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${RSENV_ROOT}/versions" ]
  run rsenv-version
  assert_success "system (set by ${RSENV_ROOT}/version)"
}

@test "set by RSENV_VERSION" {
  create_version "0.9"
  RSENV_VERSION=0.9 run rsenv-version
  assert_success "0.9 (set by RSENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "0.9"
  cat > ".rust-version" <<<"0.9"
  run rsenv-version
  assert_success "0.9 (set by ${PWD}/.rust-version)"
}

@test "set by global file" {
  create_version "0.9"
  cat > "${RSENV_ROOT}/version" <<<"0.9"
  run rsenv-version
  assert_success "0.9 (set by ${RSENV_ROOT}/version)"
}
