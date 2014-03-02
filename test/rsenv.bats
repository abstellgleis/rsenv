#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run rsenv
  assert_success
  assert [ "${lines[0]}" = "rsenv 0.1.0" ]
}

@test "invalid command" {
  run rsenv does-not-exist
  assert_failure
  assert_output "rsenv: no such command \`does-not-exist'"
}

@test "default RSENV_ROOT" {
  RSENV_ROOT="" HOME=/home/mislav run rsenv root
  assert_success
  assert_output "/home/mislav/.rsenv"
}

@test "inherited RSENV_ROOT" {
  RSENV_ROOT=/opt/rsenv run rsenv root
  assert_success
  assert_output "/opt/rsenv"
}

@test "default RSENV_DIR" {
  run rsenv echo RSENV_DIR
  assert_output "$(pwd)"
}

@test "inherited RSENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  RSENV_DIR="$dir" run rsenv echo RSENV_DIR
  assert_output "$dir"
}

@test "invalid RSENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  RSENV_DIR="$dir" run rsenv echo RSENV_DIR
  assert_failure
  assert_output "rsenv: cannot change working directory to \`$dir'"
}
