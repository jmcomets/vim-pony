" Vim plugin for working with Django projects.
" Last Change: Seg Abr 25 12:21:34 BRT 2011
" Maintainer: Rainer Borene <me@rainerborene.com>
" License: Licensed under the same terms as Vim.

if exists('g:loaded_pony')
  finish
endif
let g:loaded_pony = 1

function! s:ProjectExists()
  if !filereadable('settings.py') && !exists("$DJANGO_SETTINGS_MODULE")
    echo 'settings could not be found.'
    return 0
  endif
  return 1
endfunction

function! s:Completion(ArgLead, CmdLine, CursorPos)
  if match(a:CmdLine, 'Dadmin') >= 0
    let s:filename = 'admin.py'
  elseif match(a:CmdLine, 'Dtests') >= 0
    let s:filename = 'tests.py'
  elseif match(a:CmdLine, 'Dmodels') >= 0
    let s:filename = 'models.py'
  elseif match(a:CmdLine, 'Dviews') >= 0
    let s:filename = 'views.py'
  elseif match(a:CmdLine, 'Durls') >= 0
    let s:filename = 'urls.py'
  endif
  let s:findcmd = printf('find */ -type f -name %s | grep -oE ^[^/]+', s:filename)
  let s:folders = system(s:findcmd)
  return split(s:folders, '\n')
endfunction

function! s:DjangoGoto(app_label, name)
  if !s:ProjectExists()
    return
  endif
  if len(a:app_label) > 0
    let s:destiny = getcwd() . '/' . a:app_label . '/' . a:name . '.py'
  else
    let s:destiny = expand('%:p:h') . '/' . a:name . '.py'
  endif
  if filereadable(s:destiny)
    exec 'edit ' . s:destiny
  endif
endfunction

function! s:DjangoManage(arguments)
  if !s:ProjectExists()
    return
  endif
  exe '!export DJANGO_COLORS=nocolor && python manage.py ' . a:arguments
endfunction

function! s:DjangoRuntests(app_label)
  s:DjangoManage('test ' . a:app_label)
endfunction

command! -nargs=? -complete=customlist,s:Completion Dadmin :call s:DjangoGoto('<args>', 'admin')
command! -nargs=? -complete=customlist,s:Completion Dmodels :call s:DjangoGoto('<args>', 'models')
command! -nargs=? -complete=customlist,s:Completion Dtests :call s:DjangoGoto('<args>', 'tests')
command! -nargs=? -complete=customlist,s:Completion Dviews :call s:DjangoGoto('<args>', 'views')
command! -nargs=? -complete=customlist,s:Completion Durls :call s:DjangoGoto('<args>', 'urls')
command! -nargs=+ -bar Dmanage :call s:DjangoManage('<args>')
