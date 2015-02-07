"  private {{{1
function! s:SaveToHistory(line)
  call <SID>MakeHistoryDirectory()
  call <SID>CreateMissingHistoryFile()
  let history_file_path = <SID>HistoryFilePath()
  let current_history_contents = readfile(history_file_path)
  let updated_contents = [a:line] + current_history_contents
  call writefile(updated_contents[0:50], history_file_path)
endfunction

function! s:MakeHistoryDirectory()
  let history_directory_path = <SID>HistoryDirectoryPath()

  if !isdirectory(history_directory_path)
    call mkdir(history_directory_path)
  endif
endfunction

function! s:CreateMissingHistoryFile()
  let history_file_path = <SID>HistoryFilePath()

  if !filereadable(history_file_path)
    call system('touch ' . history_file_path)
  endif
endfunction

function! s:HistoryDirectoryPath()
  return $HOME . '/.vim/history'
endfunction

function! s:HistoryFilePath()
  let working_directory_path = substitute(getcwd(), '\/', '-', 'g')
  return <SID>HistoryDirectoryPath() . '/' . working_directory_path . '.history'
endfunction

function! s:AdjustedWindowLayout()
  if winwidth('.') > 160
    return 'vertical belowright split'
  else
    return 'belowright split'
  endif
endfunction

function! s:StripLeadingAndTrailingSpaces(string)
  return substitute(a:string, '\v(^\s*|\s*$)', '', 'g')
endfunction
" private }}}

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
    call run_tests_lib#CreateTemporaryWindow(<SID>AdjustedWindowLayout(), a:window_name)
  endif
endfunction

function! run_tests_lib#SwitchToWindow(window_number)
  execute a:window_number . 'wincmd w'
endfunction

function! run_tests_lib#CreateTemporaryWindow(split_type, window_name)
  let parent_syntax = &syntax
  let quarter_window_height = winheight('.') / 4

  execute a:split_type . ' ' . a:window_name

  execute "set syntax=" . parent_syntax
  setlocal bufhidden=wipe buftype=nofile wrap
  let s:results_window_number = winnr()

  if a:split_type == 'belowright split' && quarter_window_height >= 10
    execute 'resize -' . quarter_window_height
  end

  inoremap <buffer> <C-m> <ESC>:call <SID>SaveAndSendCurrentLineToJob()<CR>
  inoremap <buffer> <F6>n <C-R>=run_tests_lib#GetMatchingHistory()<CR>
  nnoremap <buffer> <F6>nn :call jobsend(g:current_tests_job, "next\n")<CR>
endfunction

function! run_tests_lib#GetMatchingHistory()
  call complete(col('.'), readfile(<SID>HistoryFilePath()))
  return ''
endfunction

function! s:SaveAndSendCurrentLineToJob()
  let current_line_contents = <SID>StripLeadingAndTrailingSpaces(getline('.'))
  if len(current_line_contents) > 1
    call <SID>SaveToHistory(current_line_contents)
  endif
  " Without this, the input would be printed twice.
  normal! dd
  silent! call jobsend(g:current_tests_job, current_line_contents . "\n")
endfunction

function! run_tests_lib#ClearScreen()
  normal! ggdG
endfunction

function! run_tests_lib#ResultsWindowNumber()
  return s:results_window_number
endfunction
