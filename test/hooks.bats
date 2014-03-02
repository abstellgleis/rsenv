#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run rsenv-hooks
  assert_failure "Usage: rsenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${RSENV_TEST_DIR}/rsenv.d"
  path2="${RSENV_TEST_DIR}/etc/rsenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

  RSENV_HOOK_PATH="$path1:$path2" run rsenv-hooks exec
  assert_success
  assert_output <<OUT
${RSENV_TEST_DIR}/rsenv.d/exec/ahoy.bash
${RSENV_TEST_DIR}/rsenv.d/exec/hello.bash
${RSENV_TEST_DIR}/etc/rsenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${RSENV_TEST_DIR}/my hooks/rsenv.d"
  path2="${RSENV_TEST_DIR}/etc/rsenv hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path2" exec "ahoy.bash"

  RSENV_HOOK_PATH="$path1:$path2" run rsenv-hooks exec
  assert_success
  assert_output <<OUT
${RSENV_TEST_DIR}/my hooks/rsenv.d/exec/hello.bash
${RSENV_TEST_DIR}/etc/rsenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  path="${RSENV_TEST_DIR}/rsenv.d"
  create_hook "$path" exec "hello.bash"
  mkdir -p "$HOME"

  RSENV_HOOK_PATH="${HOME}/../rsenv.d" run rsenv-hooks exec
  assert_success "${RSENV_TEST_DIR}/rsenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${RSENV_TEST_DIR}/rsenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"

  RSENV_HOOK_PATH="$path" run rsenv-hooks exec
  assert_success "${HOME}/hola.bash"
}
