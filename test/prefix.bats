#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${RSENV_TEST_DIR}/myproject"
  cd "${RSENV_TEST_DIR}/myproject"
  echo "1.2.3" > .rust-version
  mkdir -p "${RSENV_ROOT}/versions/1.2.3"
  run rsenv-prefix
  assert_success "${RSENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  RSENV_VERSION="1.2.3" run rsenv-prefix
  assert_failure "rsenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${RSENV_TEST_DIR}/bin"
  touch "${RSENV_TEST_DIR}/bin/rust"
  chmod +x "${RSENV_TEST_DIR}/bin/rust"
  RSENV_VERSION="system" run rsenv-prefix
  assert_success "$RSENV_TEST_DIR"
}

@test "prefix for invalid system" {
  PATH="$(path_without rust)" run rsenv-prefix system
  assert_failure "rsenv: system version not found in PATH"
}
