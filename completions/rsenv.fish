function __fish_rsenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'rsenv' ]
    return 0
  end
  return 1
end

function __fish_rsenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c rsenv -n '__fish_rsenv_needs_command' -a '(rsenv commands)'
for cmd in (rsenv commands)
  complete -f -c rsenv -n "__fish_rsenv_using_command $cmd" -a "(rsenv completions $cmd)"
end
