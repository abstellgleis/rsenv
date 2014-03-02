#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${RSENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "finds versions where present" {
  create_executable "0.8" "rust"
  create_executable "0.8" "rake"
  create_executable "0.10-pre" "rust"
  create_executable "0.10-pre" "rspec"

  run rsenv-whence rust
  assert_success
  assert_output <<OUT
0.10-pre
0.8
OUT

  run rsenv-whence rake
  assert_success "0.8"

  run rsenv-whence rspec
  assert_success "0.10-pre"
}
