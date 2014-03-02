#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${RSENV_ROOT}/versions/${RSENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export RSENV_VERSION="0.10-pre"
  run rsenv-exec rust -v
  assert_failure "rsenv: version \`0.10-pre' is not installed"
}

@test "completes with names of executables" {
  export RSENV_VERSION="0.10-pre"
  create_executable "rust" "#!/bin/sh"
  create_executable "rake" "#!/bin/sh"

  rsenv-rehash
  run rsenv-completions exec
  assert_success
  assert_output <<OUT
rake
rust
OUT
}

@test "supports hook path with spaces" {
  hook_path="${RSENV_TEST_DIR}/custom stuff/rsenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export RSENV_VERSION=system
  RSENV_HOOK_PATH="$hook_path" run rsenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${RSENV_TEST_DIR}/rsenv.d"
  mkdir -p "${hook_path}/exec"
  cat > "${hook_path}/exec/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export RSENV_VERSION=system
  RSENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run rsenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export RSENV_VERSION="0.10-pre"
  create_executable "rust" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run rsenv-exec rust -w "/path to/rust script.rb" -- extra args
  assert_success
  assert_output <<OUT
${RSENV_ROOT}/versions/0.10-pre/bin/rust
  -w
  /path to/rust script.rb
  --
  extra
  args
OUT
}

@test "supports rust -S <cmd>" {
  export RSENV_VERSION="0.10-pre"

  # emulate `rust -S' behavior
  create_executable "rust" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${RUSTPATH:-\$PATH}" which \$2)"
  # assert that the found executable has rust for shebang
  if head -1 "\$found" | grep rust >/dev/null; then
    \$BASH "\$found"
  else
    echo "rust: no Rust script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'rust 0.10-pre (rsenv test)'
fi
SH

  create_executable "rake" <<SH
#!/usr/bin/env rust
echo hello rake
SH

  rsenv-rehash
  run rust -S rake
  assert_success "hello rake"
}
