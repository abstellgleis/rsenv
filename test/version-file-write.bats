#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RSENV_TEST_DIR"
  cd "$RSENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run rsenv-version-file-write
  assert_failure "Usage: rsenv version-file-write <file> <version>"
  run rsenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".rust-version" ]
  run rsenv-version-file-write ".rust-version" "0.8"
  assert_failure "rsenv: version \`0.8' not installed"
  assert [ ! -e ".rust-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${RSENV_ROOT}/versions/0.8"
  assert [ ! -e "my-version" ]
  run rsenv-version-file-write "${PWD}/my-version" "0.8"
  assert_success ""
  assert [ "$(cat my-version)" = "0.8" ]
}
