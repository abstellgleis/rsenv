#!/usr/bin/env bats

load test_helper

@test "default" {
  run rsenv global
  assert_success
  assert_output "system"
}

@test "read RSENV_ROOT/version" {
  mkdir -p "$RSENV_ROOT"
  echo "1.2.3" > "$RSENV_ROOT/version"
  run rsenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set RSENV_ROOT/version" {
  mkdir -p "$RSENV_ROOT/versions/1.2.3"
  run rsenv-global "1.2.3"
  assert_success
  run rsenv global
  assert_success "1.2.3"
}

@test "fail setting invalid RSENV_ROOT/version" {
  mkdir -p "$RSENV_ROOT"
  run rsenv-global "1.2.3"
  assert_failure "rsenv: version \`1.2.3' not installed"
}
