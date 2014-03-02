#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${RSENV_ROOT}/shims" ]
  assert [ ! -d "${RSENV_ROOT}/versions" ]
  run rsenv-init -
  assert_success
  assert [ -d "${RSENV_ROOT}/shims" ]
  assert [ -d "${RSENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run rsenv-init -
  assert_success
  assert_line "rsenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run rsenv-init - bash
  assert_success
  assert_line "source '${root}/libexec/../completions/rsenv.bash'"
}

@test "detect parent shell" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  SHELL=/bin/false run rsenv-init -
  assert_success
  assert_line "export RSENV_SHELL=bash"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run rsenv-init - fish
  assert_success
  assert_line ". '${root}/libexec/../completions/rsenv.fish'"
}

@test "fish instructions" {
  run rsenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and . (rsenv init -|psub)'
}

@test "option to skip rehash" {
  run rsenv-init - --no-rehash
  assert_success
  refute_line "rsenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run rsenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${RSENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run rsenv-init - fish
  assert_success
  assert_line 0 "setenv PATH '${RSENV_ROOT}/shims' \$PATH"
}

@test "doesn't add shims to PATH more than once" {
  export PATH="${RSENV_ROOT}/shims:$PATH"
  run rsenv-init - bash
  assert_success
  refute_line 'export PATH="'${RSENV_ROOT}'/shims:${PATH}"'
}

@test "doesn't add shims to PATH more than once (fish)" {
  export PATH="${RSENV_ROOT}/shims:$PATH"
  run rsenv-init - fish
  assert_success
  refute_line 'setenv PATH "'${RSENV_ROOT}'/shims" $PATH ;'
}
