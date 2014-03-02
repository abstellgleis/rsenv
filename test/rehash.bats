#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${RSENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${RSENV_ROOT}/shims" ]
  run rsenv-rehash
  assert_success ""
  assert [ -d "${RSENV_ROOT}/shims" ]
  rmdir "${RSENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${RSENV_ROOT}/shims"
  chmod -w "${RSENV_ROOT}/shims"
  run rsenv-rehash
  assert_failure "rsenv: cannot rehash: ${RSENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${RSENV_ROOT}/shims"
  touch "${RSENV_ROOT}/shims/.rsenv-shim"
  run rsenv-rehash
  assert_failure "rsenv: cannot rehash: ${RSENV_ROOT}/shims/.rsenv-shim exists"
}

@test "creates shims" {
  create_executable "0.8" "rust"
  create_executable "0.8" "rake"
  create_executable "0.10-pre" "rust"
  create_executable "0.10-pre" "rspec"

  assert [ ! -e "${RSENV_ROOT}/shims/rust" ]
  assert [ ! -e "${RSENV_ROOT}/shims/rake" ]
  assert [ ! -e "${RSENV_ROOT}/shims/rspec" ]

  run rsenv-rehash
  assert_success ""

  run ls "${RSENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rake
rspec
rust
OUT
}

@test "removes stale shims" {
  mkdir -p "${RSENV_ROOT}/shims"
  touch "${RSENV_ROOT}/shims/oldshim1"
  chmod +x "${RSENV_ROOT}/shims/oldshim1"

  create_executable "0.10-pre" "rake"
  create_executable "0.10-pre" "rust"

  run rsenv-rehash
  assert_success ""

  assert [ ! -e "${RSENV_ROOT}/shims/oldshim1" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "rust"
  create_executable "dirname2 preview1" "rspec"

  assert [ ! -e "${RSENV_ROOT}/shims/rust" ]
  assert [ ! -e "${RSENV_ROOT}/shims/rspec" ]

  run rsenv-rehash
  assert_success ""

  run ls "${RSENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rspec
rust
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${RSENV_TEST_DIR}/rsenv.d"
  mkdir -p "${hook_path}/rehash"
  cat > "${hook_path}/rehash/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  RSENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run rsenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "0.10-pre" "rust"
  RSENV_SHELL=bash run rsenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${RSENV_ROOT}/shims/rust" ]
}

@test "sh-rehash in fish" {
  create_executable "0.10-pre" "rust"
  RSENV_SHELL=fish run rsenv-sh-rehash
  assert_success ""
  assert [ -x "${RSENV_ROOT}/shims/rust" ]
}
