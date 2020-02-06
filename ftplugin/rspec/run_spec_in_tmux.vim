if exists('b:loaded_vim_run_tests')
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

function! s:RubyTestCommand()
  return 'bundle exec rspec '
endfunction
" end private }}}

function! s:RunTestInSplit(run_focused, repeat_previous_test)
  let s:source_file_path = expand('%:p')

  if a:run_focused
    let l:test_name_option = ':' . line('.')
  else
    let l:test_name_option = ''
  end

  let l:previous_file = expand('#')
  if !a:repeat_previous_test
    let s:ruby_command = s:RubyTestCommand() . s:source_file_path . l:test_name_option
  end
  call run_tests_lib#ReCreateTestWindow()
  call termopen(s:ruby_command)

  call <SID>SwitchToSourceWindow()

  try
    call common_functions_lib#SetAlternateFile(l:previous_file)
  catch
  endtry
endfunction

function! s:RunTest()
  let l:command = s:RubyTestCommand()

  call system("tmux send-key -t 7 '" . l:command . expand('%') . "' Enter")
endfunction

let prefix = g:vim_run_tests_prefix
execute 'nmap <buffer> ' . prefix . 'tf :call <SID>RunTestInSplit(1, 0)<CR>'
execute 'nmap <buffer> ' . prefix . 'ts :call <SID>RunTestInSplit(0, 0)<CR>'
execute 'nmap <buffer> ' . prefix . 'tt :call <SID>RunTest()<CR>'
execute 'nmap ' . prefix . 'tc :call run_tests_lib#CloseTestWindow()<CR>'
execute 'nmap ' . prefix . 'tr :call <SID>RunTestInSplit(1, 1)<CR>'
