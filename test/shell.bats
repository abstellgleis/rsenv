#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${RSENV_TEST_DIR}/myproject"
  cd "${RSENV_TEST_DIR}/myproject"
  echo "1.2.3" > .rust-version
  RSENV_VERSION="" run rsenv-sh-shell
  assert_failure "rsenv: no shell-specific version configured"
}

@test "shell version" {
  RSENV_SHELL=bash RSENV_VERSION="1.2.3" run rsenv-sh-shell
  assert_success 'echo "$RSENV_VERSION"'
}

@test "shell version (fish)" {
  RSENV_SHELL=fish RSENV_VERSION="1.2.3" run rsenv-sh-shell
  assert_success 'echo "$RSENV_VERSION"'
}

@test "shell unset" {
  RSENV_SHELL=bash run rsenv-sh-shell --unset
  assert_success "unset RSENV_VERSION"
}

@test "shell unset (fish)" {
  RSENV_SHELL=fish run rsenv-sh-shell --unset
  assert_success "set -e RSENV_VERSION"
}

@test "shell change invalid version" {
  run rsenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
rsenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${RSENV_ROOT}/versions/1.2.3"
  RSENV_SHELL=bash run rsenv-sh-shell 1.2.3
  assert_success 'export RSENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${RSENV_ROOT}/versions/1.2.3"
  RSENV_SHELL=fish run rsenv-sh-shell 1.2.3
  assert_success 'setenv RSENV_VERSION "1.2.3"'
}
