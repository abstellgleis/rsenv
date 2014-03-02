#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${RSENV_TEST_DIR}/myproject"
  cd "${RSENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.rust-version" ]
  run rsenv-local
  assert_failure "rsenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .rust-version
  run rsenv-local
  assert_success "1.2.3"
}

@test "supports legacy .rsenv-version file" {
  echo "1.2.3" > .rsenv-version
  run rsenv-local
  assert_success "1.2.3"
}

@test "local .rust-version has precedence over .rsenv-version" {
  echo "0.8" > .rsenv-version
  echo "0.10-pre" > .rust-version
  run rsenv-local
  assert_success "0.10-pre"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .rust-version
  mkdir -p "subdir" && cd "subdir"
  run rsenv-local
  assert_failure
}

@test "ignores RSENV_DIR" {
  echo "1.2.3" > .rust-version
  mkdir -p "$HOME"
  echo "0.10-pre-home" > "${HOME}/.rust-version"
  RSENV_DIR="$HOME" run rsenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${RSENV_ROOT}/versions/1.2.3"
  run rsenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .rust-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .rust-version
  mkdir -p "${RSENV_ROOT}/versions/1.2.3"
  run rsenv-local
  assert_success "1.0-pre"
  run rsenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .rust-version)" = "1.2.3" ]
}

@test "renames .rsenv-version to .rust-version" {
  echo "0.8" > .rsenv-version
  mkdir -p "${RSENV_ROOT}/versions/0.9"
  run rsenv-local
  assert_success "0.8"
  run rsenv-local "0.9"
  assert_success
  assert_output <<OUT
rsenv: removed existing \`.rsenv-version' file and migrated
       local version specification to \`.rust-version' file
OUT
  assert [ ! -e .rsenv-version ]
  assert [ "$(cat .rust-version)" = "0.9" ]
}

@test "doesn't rename .rsenv-version if changing the version failed" {
  echo "0.8" > .rsenv-version
  assert [ ! -e "${RSENV_ROOT}/versions/0.9" ]
  run rsenv-local "0.9"
  assert_failure "rsenv: version \`0.9' not installed"
  assert [ ! -e .rust-version ]
  assert [ "$(cat .rsenv-version)" = "0.8" ]
}

@test "unsets local version" {
  touch .rust-version
  run rsenv-local --unset
  assert_success ""
  assert [ ! -e .rsenv-version ]
}

@test "unsets alternate version file" {
  touch .rsenv-version
  run rsenv-local --unset
  assert_success ""
  assert [ ! -e .rsenv-version ]
}
