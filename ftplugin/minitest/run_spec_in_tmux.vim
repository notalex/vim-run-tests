if exists('b:loaded_vim_run_tests')
  finish
else
  let b:loaded_vim_run_tests = 1
endif

" private {{{1
function! s:SwitchToSourceWindow()
  wincmd p
endfunction

function! s:FocusedTestName()
  " Since search backwards excludes current line, use j to move down first.
  normal! j

  let l:it_line_no = search('\v\s(it|test).+do$', 'bn', 1)
  let l:def_line_no = search('\v\s+def %(\w|_)+$', 'bn', 1)

  normal! k

  if l:it_line_no > l:def_line_no
    let l:line = getline(l:it_line_no)
    let l:method_name = matchlist(l:line, '\v%("|'')(.*)%("|'')')[1]
    let l:formatted_method_name = substitute(l:method_name, '\v%( |\/)', '.', 'g')
  elseif l:def_line_no
    let l:line = getline(l:def_line_no)
    let l:formatted_method_name = matchlist(l:line, '\v^\s*def (.+)$')[1]
  endif

  if exists('l:formatted_method_name')
    let l:escaped_method_name = escape(l:formatted_method_name, '!')
    return l:escaped_method_name . '$'
  endif
endfunction

function! s:TestHelperPath()
  let s:path = expand('%:.')
  return matchstr(s:path, '\v.*test\/')
endfunction

" end private }}}

function! s:RunTestInSplit(run_focused, repeat_previous_test)
  let s:source_file_path = expand('%:p')
  let focused_test_name = <SID>FocusedTestName()

  " strlen(0) => 1
  if strlen(focused_test_name) > 1 && a:run_focused
    let test_name_option = '--name /' . focused_test_name . '/'
  else
    let test_name_option = ''
  end

  let previous_file = expand('#')
  if !a:repeat_previous_test
    let s:ruby_command = 'ruby -I test ' . s:source_file_path . ' ' . test_name_option
  end
  call run_tests_lib#ReCreateTestWindow()
  call termopen(s:ruby_command)

  call <SID>SwitchToSourceWindow()

  try
    call common_functions_lib#SetAlternateFile(previous_file)
  catch
  endtry
endfunction

function! s:RunTest()
  let l:command = 'ruby -I' . s:TestHelperPath()

  call system("tmux send-key -t 7 '" . l:command . " " . expand('%') . "' Enter")
  call run_tests_lib#Notification(7)
endfunction

nmap <buffer> <F6>tf :call <SID>RunTestInSplit(1, 0)<CR>
nmap <buffer> <F6>ts :call <SID>RunTestInSplit(0, 0)<CR>
nmap <buffer> <F6>tt :call <SID>RunTest()<CR>
nmap <F6>tc :call run_tests_lib#CloseTestWindow()<CR>
nmap <F6>tr :call <SID>RunTestInSplit(1, 1)<CR>
