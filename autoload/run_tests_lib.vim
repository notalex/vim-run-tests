function! run_tests_lib#Notification(target)
  call system("tmux send-key -t " . a:target . " 'notify-send -t 2000 Done' Enter ")
endfunction

function! run_tests_lib#SporkPresent()
  return strlen(system('pidof spork'))
endfunction

function! run_tests_lib#ZeusPresent()
  return getfsize('.zeus.sock') >= 0
endfunction

function! run_tests_lib#ZeusCommand()
  return 'zeus test'
endfunction
