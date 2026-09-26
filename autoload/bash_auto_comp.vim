function! bash_auto_comp#completor(opt, ctx) abort
  " these will be passed to asyncomplete#complete()
  let l:state = {
        \ 'opt_name': a:opt['name'],
        \ 'ctx': a:ctx,
        \ 'col': a:ctx['col']
        \ }
  let l:lnum = a:ctx['lnum']  " line number
  let l:col   = a:ctx['col']  " column number
  let l:typed = a:ctx['typed'][:l:col] " typed line

  " if previous line ends with a backslash prepend it to typed
  while l:lnum > 1
    let l:lnum -= 1
    let l:prev_line = getline(l:lnum)
    if l:prev_line =~# '\\$'
      let l:typed = trim(l:prev_line[0:-2]) .. ' ' .. l:typed
    else
      break
    endif
  endwhile

  " if there's | or ; or ( in the typed line, use the part behind it
  let l:typed = split(l:typed, '|\|;\|(')[-1]
  let l:cmd = 'exec ' .. fnameescape(expand('<script>:p:h'))
        \ .. '/' .. 'bash_auto_comp.sh' .. ' "' .. l:typed .. '"'

  " do not wait for the job to finish, job will pass output to BashHandler
  let s:bash_job = job_start(
        \[
        \   'bash',
        \   '-c',
        \   l:cmd,
        \],
        \{
        \   'out_cb': function('BashHandler', [l:state]),
        \   'mode': 'raw',
        \})
endfunction

" job callback for when there is something to read on stdout
function! BashHandler(state, channel, msg) abort
  let l:col = a:state['col']
  let l:result = split(a:msg, '\n')

  if len(l:result) < 2
    return
  endif

  let l:kw = l:result[0]
  let l:kwlen = len(l:kw)
  let l:startcol = l:col - l:kwlen

  let l:matches = sort(l:result[1:])
  let l:matches = sort(l:matches, {a, b -> len(a) - len(b)})

  call asyncomplete#complete(
        \ a:state['opt_name'],
        \ a:state['ctx'],
        \ l:startcol,
        \ l:matches
        \)
endfunction
