#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${RSENV_TEST_DIR}/myproject"
  cd "${RSENV_TEST_DIR}/myproject"
}

@test "fails without arguments" {
  run rsenv-version-file-read
  assert_failure ""
}

@test "fails for invalid file" {
  run rsenv-version-file-read "non-existent"
  assert_failure ""
}

@test "fails for blank file" {
  echo > my-version
  run rsenv-version-file-read my-version
  assert_failure ""
}

@test "reads simple version file" {
  cat > my-version <<<"0.9"
  run rsenv-version-file-read my-version
  assert_success "0.9"
}

@test "ignores leading spaces" {
  cat > my-version <<<"  0.9"
  run rsenv-version-file-read my-version
  assert_success "0.9"
}

@test "reads only the first word from file" {
  cat > my-version <<<"0.9-p194@tag 0.8 hi"
  run rsenv-version-file-read my-version
  assert_success "0.9-p194@tag"
}

@test "loads only the first line in file" {
  cat > my-version <<IN
0.8 one
0.9 two
IN
  run rsenv-version-file-read my-version
  assert_success "0.8"
}

@test "ignores leading blank lines" {
  cat > my-version <<IN

0.9
IN
  run rsenv-version-file-read my-version
  assert_success "0.9"
}

@test "handles the file with no trailing newline" {
  echo -n "0.8" > my-version
  run rsenv-version-file-read my-version
  assert_success "0.8"
}
