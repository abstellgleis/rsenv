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
  run rsenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  RSENV_VERSION=system run rsenv-version-name
  assert_success "system"
}

@test "RSENV_VERSION has precedence over local" {
  create_version "0.8"
  create_version "0.9"

  cat > ".rust-version" <<<"0.8"
  run rsenv-version-name
  assert_success "0.8"

  RSENV_VERSION=0.9 run rsenv-version-name
  assert_success "0.9"
}

@test "local file has precedence over global" {
  create_version "0.8"
  create_version "0.9"

  cat > "${RSENV_ROOT}/version" <<<"0.8"
  run rsenv-version-name
  assert_success "0.8"

  cat > ".rust-version" <<<"0.9"
  run rsenv-version-name
  assert_success "0.9"
}

@test "missing version" {
  RSENV_VERSION=1.2 run rsenv-version-name
  assert_failure "rsenv: version \`1.2' is not installed"
}

@test "version with prefix in name" {
  create_version "0.8"
  cat > ".rust-version" <<<"rust-0.8"
  run rsenv-version-name
  assert_success
  assert_output <<OUT
warning: ignoring extraneous \`rust-' prefix in version \`rust-0.8'
         (set by ${PWD}/.rust-version)
0.8
OUT
}
