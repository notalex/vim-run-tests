if exists('g:vim_tests_resize')
  finish
else
  let g:vim_tests_resize = 0
endif

"  private {{{1
function! s:AdjustedWindowLayout()
  if winwidth('.') > 158
    return 'vertical belowright split'
  else
    return 'belowright split'
  endif
endfunction

function! s:CreateTemporaryWindow(split_type)
  let quarter_window_height = winheight('.') / 4

  execute a:split_type . ' vnew'
  set syntax=sh

  let s:results_buffer_number = bufnr('%')

  if g:vim_tests_resize && a:split_type == 'belowright split' && quarter_window_height >= 10
    execute 'resize -' . quarter_window_height
  end
endfunction
" private }}}

function! run_tests_lib#Notification(target)
  call system("tmux send-key -t " . a:target . " 'notify-send -t 2000 Done' Enter ")
endfunction

function! run_tests_lib#ReCreateTestWindow()
  call run_tests_lib#CloseTestWindow()
  call <SID>CreateTemporaryWindow(<SID>AdjustedWindowLayout())
endfunction

function! run_tests_lib#CloseTestWindow()
  if exists('s:results_buffer_number')
    execute 'silent! bdelete! ' . s:results_buffer_number
  endif
endfunction
