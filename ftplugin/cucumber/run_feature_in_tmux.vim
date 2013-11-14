function! s:FocusedTestName()
  let s:focused_test_name = expand('%:p') . ':' . line('.')
  return s:focused_test_name
endfunction

function! s:RunFocusedTest()
  call system("tmux send-key -t 7 'cucumber " . s:FocusedTestName() . "' Enter")
  call run_tests_lib#Notification(7)
endfunction

function! s:RunTest()
  call system("tmux send-key -t 7 'cucumber " . expand('%:p') . "' Enter")
  call run_tests_lib#Notification(7)
endfunction

nmap <buffer> <F6>rs :call <SID>RunFocusedTest()<CR>
nmap <buffer> <F6>a :call <SID>RunTest()<CR>
