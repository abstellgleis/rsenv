#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$RSENV_TEST_DIR"
  cd "$RSENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${RSENV_ROOT}/version" ]
  assert [ ! -e ".rust-version" ]
  run rsenv-version-file
  assert_success "${RSENV_ROOT}/version"
}

@test "detects 'global' file" {
  create_file "${RSENV_ROOT}/global"
  run rsenv-version-file
  assert_success "${RSENV_ROOT}/global"
}

@test "detects 'default' file" {
  create_file "${RSENV_ROOT}/default"
  run rsenv-version-file
  assert_success "${RSENV_ROOT}/default"
}

@test "'version' has precedence over 'global' and 'default'" {
  create_file "${RSENV_ROOT}/version"
  create_file "${RSENV_ROOT}/global"
  create_file "${RSENV_ROOT}/default"
  run rsenv-version-file
  assert_success "${RSENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".rust-version"
  run rsenv-version-file
  assert_success "${RSENV_TEST_DIR}/.rust-version"
}

@test "legacy file in current directory" {
  create_file ".rsenv-version"
  run rsenv-version-file
  assert_success "${RSENV_TEST_DIR}/.rsenv-version"
}

@test ".rust-version has precedence over legacy file" {
  create_file ".rust-version"
  create_file ".rsenv-version"
  run rsenv-version-file
  assert_success "${RSENV_TEST_DIR}/.rust-version"
}

@test "in parent directory" {
  create_file ".rust-version"
  mkdir -p project
  cd project
  run rsenv-version-file
  assert_success "${RSENV_TEST_DIR}/.rust-version"
}

@test "topmost file has precedence" {
  create_file ".rust-version"
  create_file "project/.rust-version"
  cd project
  run rsenv-version-file
  assert_success "${RSENV_TEST_DIR}/project/.rust-version"
}

@test "legacy file has precedence if higher" {
  create_file ".rust-version"
  create_file "project/.rsenv-version"
  cd project
  run rsenv-version-file
  assert_success "${RSENV_TEST_DIR}/project/.rsenv-version"
}

@test "RSENV_DIR has precedence over PWD" {
  create_file "widget/.rust-version"
  create_file "project/.rust-version"
  cd project
  RSENV_DIR="${RSENV_TEST_DIR}/widget" run rsenv-version-file
  assert_success "${RSENV_TEST_DIR}/widget/.rust-version"
}

@test "PWD is searched if RSENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.rust-version"
  cd project
  RSENV_DIR="${RSENV_TEST_DIR}/widget/blank" run rsenv-version-file
  assert_success "${RSENV_TEST_DIR}/project/.rust-version"
}
