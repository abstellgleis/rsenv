if [[ ! -o interactive ]]; then
    return
fi

compctl -K _rsenv rsenv

_rsenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(rsenv commands)"
  else
    completions="$(rsenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
