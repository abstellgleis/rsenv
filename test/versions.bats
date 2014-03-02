#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${RSENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$RSENV_TEST_DIR"
  cd "$RSENV_TEST_DIR"
}

stub_system_rust() {
  local stub="${RSENV_TEST_DIR}/bin/rust"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_rust
  assert [ ! -d "${RSENV_ROOT}/versions" ]
  run rsenv-versions
  assert_success "* system (set by ${RSENV_ROOT}/version)"
}

@test "bare output no versions installed" {
  assert [ ! -d "${RSENV_ROOT}/versions" ]
  run rsenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_rust
  create_version "0.9"
  run rsenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${RSENV_ROOT}/version)
  0.9
OUT
}

@test "single version bare" {
  create_version "0.9"
  run rsenv-versions --bare
  assert_success "0.9"
}

@test "multiple versions" {
  stub_system_rust
  create_version "0.8"
  create_version "0.9"
  create_version "0.10-pre"
  run rsenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${RSENV_ROOT}/version)
  0.10-pre
  0.8
  0.9
OUT
}

@test "indicates current version" {
  stub_system_rust
  create_version "0.9"
  create_version "0.10-pre"
  RSENV_VERSION=0.9 run rsenv-versions
  assert_success
  assert_output <<OUT
  system
  0.10-pre
* 0.9 (set by RSENV_VERSION environment variable)
OUT
}

@test "bare doesn't indicate current version" {
  create_version "0.9"
  create_version "0.10-pre"
  RSENV_VERSION=0.9 run rsenv-versions --bare
  assert_success
  assert_output <<OUT
0.10-pre
0.9
OUT
}

@test "globally selected version" {
  stub_system_rust
  create_version "0.9"
  create_version "0.10-pre"
  cat > "${RSENV_ROOT}/version" <<<"0.9"
  run rsenv-versions
  assert_success
  assert_output <<OUT
  system
  0.10-pre
* 0.9 (set by ${RSENV_ROOT}/version)
OUT
}

@test "per-project version" {
  stub_system_rust
  create_version "0.9"
  create_version "0.10-pre"
  cat > ".rust-version" <<<"0.9"
  run rsenv-versions
  assert_success
  assert_output <<OUT
  system
  0.10-pre
* 0.9 (set by ${RSENV_TEST_DIR}/.rust-version)
OUT
}
