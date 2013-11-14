function! run_tests_lib#Notification(target)
  call system("tmux send-key -t " . a:target . " 'notify-send -t 2000 Done' Enter ")
endfunction

