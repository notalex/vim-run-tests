function! s:FocusedTestName()
  " Since search backwards excludes current line, use j to move down first.
  normal! j

  let l:it_line_no = search('\v\s(it|test).+do$', 'bn', 1)
  let l:def_line_no = search('\v\s+def %(\w|_)+$', 'bn', 1)

  normal! k

  if l:it_line_no
    let l:line = getline(l:it_line_no)
    let l:method_name = matchlist(l:line, '\v"(.+)"')[1]
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

function! s:SwitchOrCreateResultsPane()
  if system('tmux list-panes | wc -l') == 2
    call system('tmux select-pane -t 1')
  else
    call system('tmux split-window')
  endif
endfunction

function! s:SporkPresent()
  return strlen(system('pidof spork'))
endfunction

function! s:TestHelperPath()
  let s:path = expand('%:.')
  return matchstr(s:path, '\v.*test\/')
endfunction

function! s:RunTestInSplit(run_focused)
  call s:SwitchOrCreateResultsPane()

  " strlen(0) => 1
  if strlen(s:FocusedTestName()) > 1 && a:run_focused
    let l:test_name_option = '--name /' . s:FocusedTestName() . '/'
  else
    let l:test_name_option = ''
  end

  if s:SporkPresent()
    let l:command = 'testdrb ' . expand('%') .  ' --'
  else
    let l:command = 'ruby -I' . s:TestHelperPath() . ' ' .  expand('%')
  endif

  call system("tmux send-key -t 1 '" . l:command . " " . l:test_name_option . "' Enter")
  call system("tmux last-pane")
endfunction

function! s:RunTest()
  if s:SporkPresent()
    let l:command = 'testdrb'
  else
    let l:command = 'ruby -I' . s:TestHelperPath()
  endif

  call system("tmux send-key -t 7 '" . l:command . " " . expand('%') .
    \ run_tests_lib#Notification() . "' Enter")
endfunction

nmap <buffer> <F6>rf :call <SID>RunTestInSplit(1)<CR>
nmap <buffer> <F6>rs :call <SID>RunTestInSplit(0)<CR>
nmap <buffer> <F6>rt :call <SID>RunTest()<CR>
