if exists('b:loaded_vim_run_tests') || !strlen(matchstr(expand('%'), '_spec.cr$'))
  finish
else
  let b:loaded_vim_run_tests = 1
endif

if !exists('g:vim_run_tests_prefix')
  let g:vim_run_tests_prefix = '<leader>'
endif

" private {{{1
function! s:SwitchToSourceWindow()
  wincmd p
endfunction

function! s:FocusedTestLineNumber()
  " Since search backwards excludes current line, use j to move down first.
  normal! j
  let l:line_number = search('\v\sit.+do$', 'bn', 1)
  normal! k
  return l:line_number
endfunction
" end private }}}

function! s:RunTestInSplit(run_focused, repeat_previous_test)
  let s:source_file_path = expand('%')
  let l:focused_line_number = <SID>FocusedTestLineNumber()

  " strlen(0) => 1
  if l:focused_line_number > 1 && a:run_focused
    let l:test_opts = ':' . l:focused_line_number
  else
    let l:test_opts = ''
  end

  let l:previous_file = expand('#')
  if !a:repeat_previous_test
    let s:crystal_command = 'crystal spec ' . s:source_file_path . l:test_opts
  end
  call run_tests_lib#ReCreateTestWindow()
  call termopen(s:crystal_command)

  call <SID>SwitchToSourceWindow()

  try
    call common_functions_lib#SetAlternateFile(l:previous_file)
  catch
  endtry
endfunction

function! s:RunTest()
  let l:command = 'crystal spec'

  call system("tmux send-key -t 7 '" . l:command . " " . expand('%') . "' Enter")
  call run_tests_lib#Notification(7)
endfunction

let prefix = g:vim_run_tests_prefix
execute 'nmap <buffer> ' . prefix . 'tf :call <SID>RunTestInSplit(1, 0)<CR>'
execute 'nmap <buffer> ' . prefix . 'ts :call <SID>RunTestInSplit(0, 0)<CR>'
execute 'nmap <buffer> ' . prefix . 'tt :call <SID>RunTest()<CR>'
execute 'nmap ' . prefix . 'tc :call run_tests_lib#CloseTestWindow()<CR>'
execute 'nmap ' . prefix . 'tr :call <SID>RunTestInSplit(1, 1)<CR>'
