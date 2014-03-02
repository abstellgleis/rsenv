#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run rsenv-help
  assert_success
  assert_line "Usage: rsenv <command> [<args>]"
  assert_line "Some useful rsenv commands are:"
}

@test "invalid command" {
  run rsenv-help hello
  assert_failure "rsenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${RSENV_TEST_DIR}/bin"
  cat > "${RSENV_TEST_DIR}/bin/rsenv-hello" <<SH
#!shebang
# Usage: rsenv hello <world>
# Summary: Says "hello" to you, from rsenv
# This command is useful for saying hello.
echo hello
SH

  run rsenv-help hello
  assert_success
  assert_output <<SH
Usage: rsenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${RSENV_TEST_DIR}/bin"
  cat > "${RSENV_TEST_DIR}/bin/rsenv-hello" <<SH
#!shebang
# Usage: rsenv hello <world>
# Summary: Says "hello" to you, from rsenv
echo hello
SH

  run rsenv-help hello
  assert_success
  assert_output <<SH
Usage: rsenv hello <world>

Says "hello" to you, from rsenv
SH
}

@test "extracts only usage" {
  mkdir -p "${RSENV_TEST_DIR}/bin"
  cat > "${RSENV_TEST_DIR}/bin/rsenv-hello" <<SH
#!shebang
# Usage: rsenv hello <world>
# Summary: Says "hello" to you, from rsenv
# This extended help won't be shown.
echo hello
SH

  run rsenv-help --usage hello
  assert_success "Usage: rsenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${RSENV_TEST_DIR}/bin"
  cat > "${RSENV_TEST_DIR}/bin/rsenv-hello" <<SH
#!shebang
# Usage: rsenv hello <world>
#        rsenv hi [everybody]
#        rsenv hola --translate
# Summary: Says "hello" to you, from rsenv
# Help text.
echo hello
SH

  run rsenv-help hello
  assert_success
  assert_output <<SH
Usage: rsenv hello <world>
       rsenv hi [everybody]
       rsenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${RSENV_TEST_DIR}/bin"
  cat > "${RSENV_TEST_DIR}/bin/rsenv-hello" <<SH
#!shebang
# Usage: rsenv hello <world>
# Summary: Says "hello" to you, from rsenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run rsenv-help hello
  assert_success
  assert_output <<SH
Usage: rsenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
