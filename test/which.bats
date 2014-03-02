#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${RSENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "0.8" "rust"
  create_executable "0.10-pre" "rspec"

  RSENV_VERSION=0.8 run rsenv-which rust
  assert_success "${RSENV_ROOT}/versions/0.8/bin/rust"

  RSENV_VERSION=0.10-pre run rsenv-which rspec
  assert_success "${RSENV_ROOT}/versions/0.10-pre/bin/rspec"
}

@test "searches PATH for system version" {
  create_executable "${RSENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${RSENV_ROOT}/shims" "kill-all-humans"

  RSENV_VERSION=system run rsenv-which kill-all-humans
  assert_success "${RSENV_TEST_DIR}/bin/kill-all-humans"
}

@test "version not installed" {
  create_executable "0.10-pre" "rspec"
  RSENV_VERSION=0.9 run rsenv-which rspec
  assert_failure "rsenv: version \`0.9' is not installed"
}

@test "no executable found" {
  create_executable "0.8" "rspec"
  RSENV_VERSION=0.8 run rsenv-which rake
  assert_failure "rsenv: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "0.8" "rust"
  create_executable "0.9" "rspec"
  create_executable "0.10-pre" "rspec"

  RSENV_VERSION=0.8 run rsenv-which rspec
  assert_failure
  assert_output <<OUT
rsenv: rspec: command not found

The \`rspec' command exists in these Rust versions:
  0.10-pre
  0.9
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${RSENV_TEST_DIR}/rsenv.d"
  mkdir -p "${hook_path}/which"
  cat > "${hook_path}/which/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  RSENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run rsenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}
