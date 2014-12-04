if exists('b:loaded_vim_run_tests')
  finish
else
  let b:loaded_vim_run_tests = 1
endif

" private {{{1

function! s:ResultsWindowName()
  return '__Ruby_Test_Results__'
endfunction

function! s:SwitchToSourceWindow()
  call run_tests_lib#SwitchToWindow(s:source_window_number)
endfunction

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

function! s:TestHelperPath()
  let s:path = expand('%:.')
  return matchstr(s:path, '\v.*test\/')
endfunction

function! s:SwitchToResultsWindow()
  call run_tests_lib#FindOrCreateWindowByName(<SID>ResultsWindowName())
endfunction

" end private }}}

function! s:RunTestInSplit(run_focused)
  let s:source_window_number = winnr()
  let s:source_file_path = expand('%:p')
  let focused_test_name = <SID>FocusedTestName()

  " strlen(0) => 1
  if strlen(focused_test_name) > 1 && a:run_focused
    let test_name_option = ['--name', '/' . focused_test_name . '/']
  else
    let test_name_option = []
  end

  call <SID>SwitchToResultsWindow()
  call run_tests_lib#ClearScreen()
  call <SID>SwitchToSourceWindow()

  let ruby_command = ['-r', '/tmp/opts.rb', '-I', 'test'] + [s:source_file_path] + test_name_option
  let s:current_job = jobstart('test_runner', 'ruby', ruby_command)

  autocmd! JobActivity test_runner call <SID>JobHandler()
endfunction

function! s:JobHandler()
  if v:job_data[1] == 'exit'
    let str = 'job '.v:job_data[0].' exited'
  else
    let str = join(v:job_data[2])
  endif

  call <SID>SwitchToResultsWindow()
  call append(line('$'), str)
  call <SID>SwitchToSourceWindow()
endfunction

nmap <buffer> <F6>rf :call <SID>RunTestInSplit(1)<CR>
nmap <buffer> <F6>rs :call <SID>RunTestInSplit(0)<CR>
