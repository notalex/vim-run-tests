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
    let test_name_option = ['--name', '/' . focused_test_name . '/']
  else
    let test_name_option = []
  end

  let previous_file = expand('#')
  call run_tests_lib#FindOrCreateWindowByName(<SID>ResultsWindowName())
  call run_tests_lib#ClearScreen()
  call <SID>SwitchToSourceWindow()
  call common_functions_lib#SetAlternateFile(previous_file)

  if !exists('g:ruby_test_opts_path')
    let g:ruby_test_opts_path = tempname() . '.rb'
    call writefile(['$stdout.sync = true'], g:ruby_test_opts_path)
  endif

  if !a:repeat_previous_test
    let s:ruby_command = ['-r', g:ruby_test_opts_path, '-I', 'test'] + [s:source_file_path] + test_name_option
  endif
  let g:current_tests_job = jobstart('test_runner', 'ruby', s:ruby_command)

  autocmd! JobActivity test_runner call <SID>JobHandler()
endfunction

function! s:JobHandler()
  if v:job_data[1] == 'exit'
    let lines = []
  else
    let lines = v:job_data[2]
  endif

  if len(lines) && !strlen(matchstr(lines[0], '\vBundler::GemNotFound'))
    let was_outside_results_window = winnr() != run_tests_lib#ResultsWindowNumber()

    if run_tests_lib#SwitchToResultsWindow(<SID>ResultsWindowName())
      for line in lines
        call append(line('$'), line)
      endfor

      normal! G

      if was_outside_results_window
        call <SID>SwitchToSourceWindow()
      endif
    end
  endif
endfunction

function! s:CloseTestWindow()
  silent! call jobstop(g:current_tests_job)
  execute 'bdelete ' . <SID>ResultsWindowName()
endfunction

function! s:RunTest()
  let l:command = 'ruby -I' . s:TestHelperPath()

  call system("tmux send-key -t 7 '" . l:command . " " . expand('%') . "' Enter")
  call run_tests_lib#Notification(7)
endfunction

nmap <buffer> <F6>tf :call <SID>RunTestInSplit(1, 0)<CR>
nmap <buffer> <F6>ts :call <SID>RunTestInSplit(0, 0)<CR>
nmap <buffer> <F6>tt :call <SID>RunTest()<CR>
nmap <F6>tc :call <SID>CloseTestWindow()<CR>
nmap <F6>tr :call <SID>RunTestInSplit(1, 1)<CR>
