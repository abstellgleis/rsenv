#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run rsenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${RSENV_ROOT}/shims"
  touch "${RSENV_ROOT}/shims/rust"
  touch "${RSENV_ROOT}/shims/irb"
  run rsenv-shims
  assert_success
  assert_line "${RSENV_ROOT}/shims/rust"
  assert_line "${RSENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${RSENV_ROOT}/shims"
  touch "${RSENV_ROOT}/shims/rust"
  touch "${RSENV_ROOT}/shims/irb"
  run rsenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "rust"
}
