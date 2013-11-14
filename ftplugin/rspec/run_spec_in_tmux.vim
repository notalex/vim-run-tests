function! s:FocusedTestName()
  let s:focused_test_name = expand('%:p') . ':' . line('.')
  return s:focused_test_name
endfunction

function! s:SwitchOrCreateResultsPane()
  if system('tmux list-panes | wc -l') == 2
    call system('tmux select-pane -t 1')
  else
    call system('tmux split-window')
  endif
endfunction

function! s:RunTest()
  call system("tmux send-key -t 7 'rspec " . expand('%:p') . run_tests_lib#Notification() . "' Enter")
endfunction

function! s:RunTestInSplit(run_focused)
  call s:SwitchOrCreateResultsPane()

  if a:run_focused
    let l:file_name = s:FocusedTestName()
  else
    let l:file_name = expand('%')
  endif

  call system("tmux send-key -t 1 'rspec " . l:file_name . "' Enter")

  call system("tmux last-pane")
endfunction

nmap <buffer> <F6>rf :call <SID>RunTestInSplit(1)<CR>
nmap <buffer> <F6>rs :call <SID>RunTestInSplit(0)<CR>
nmap <buffer> <F6>rt :call <SID>RunTest()<CR>
