#!/usr/bin/env bats

load test_helper

create_command() {
  bin="${RSENV_TEST_DIR}/bin"
  mkdir -p "$bin"
  echo "$2" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

@test "command with no completion support" {
  create_command "rsenv-hello" "#!$BASH
    echo hello"
  run rsenv-completions hello
  assert_success ""
}

@test "command with completion support" {
  create_command "rsenv-hello" "#!$BASH
# Provide rsenv completions
if [[ \$1 = --complete ]]; then
  echo hello
else
  exit 1
fi"
  run rsenv-completions hello
  assert_success "hello"
}

@test "forwards extra arguments" {
  create_command "rsenv-hello" "#!$BASH
# provide rsenv completions
if [[ \$1 = --complete ]]; then
  shift 1
  for arg; do echo \$arg; done
else
  exit 1
fi"
  run rsenv-completions hello happy world
  assert_success
  assert_output <<OUT
happy
world
OUT
}
