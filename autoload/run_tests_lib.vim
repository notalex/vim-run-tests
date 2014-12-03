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

function! run_tests_lib#FindOrCreateWindowByName(window_name)
  let l:window_number = bufwinnr(a:window_name . '$')

  if l:window_number > 0
    call run_tests_lib#SwitchToWindow(l:window_number)
  else
    call run_tests_lib#CreateTemporaryWindow('rightbelow split', a:window_name)
  endif
endfunction

function! run_tests_lib#SwitchToWindow(window_number)
  execute a:window_number . 'wincmd w'
endfunction

function! run_tests_lib#CreateTemporaryWindow(split_type, window_name)
  execute a:split_type . ' ' . a:window_name
  setlocal bufhidden=wipe buftype=nofile
  resize -15
endfunction

function! run_tests_lib#ClearScreen()
  normal! ggdG
endfunction
