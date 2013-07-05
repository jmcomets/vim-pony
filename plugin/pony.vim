" Vim plugin for working with Django projects.
" Author: Rainer Borene <me@rainerborene.com>
" Licensed under the same terms as Vim.
"
" Maintainer: Jean-Marie Comets <jean.marie.comets@gmail.com>

if exists("g:loaded_pony")
  finish
endif
let g:loaded_pony = 1

" Configuration for "manage" script name
let g:pony_manage_filename = "manage.py"
" function to wrap the check on this file
function! s:ManageExists()
  return filereadable(g:pony_manage_filename)
endfunction

" Script error function, preferred to echoerr
function! s:Error(msg)
  echohl WarningMsg
  echo a:msg
  echohl None
endfunction

" Refactored to regroup this, maybe checks will be made or settings
" will be added (as a g:pony_python_cmd variable ?)
let s:python_cmd = "python"

" Dictionary containing mapping from command to possible files
let s:goto_complete_dict = {
      \ "admin"    : "admin.py",
      \ "models"   : "models.py",
      \ "settings" : "settings.py",
      \ "tests"    : "tests.py",
      \ "urls"     : "urls.py",
      \ "views"    : "views.py"
      \ }

" Available commands for DjangoGoTo
let s:goto_possible_keys = keys(s:goto_complete_dict)

" Prefix for Pony commands
let g:pony_prefix = "D"
" helper for making command names, encapsulating the command format
function! s:RealCommandName(CommandName)
  return g:pony_prefix . a:CommandName
endfunction

" Completion for DjangoGoto
function! s:DjangoGoToComplete(ArgLead, CmdLine, CursorPos)
  " Check that there is a Goto defined for the given command
  let l:cmd_name = split(split(a:CmdLine, " ")[0], g:pony_prefix)[0]
  let l:goto_key_index = match(s:goto_possible_keys, l:cmd_name)
  if l:goto_key_index == -1
    return []
  endif
  let l:goto_key = s:goto_possible_keys[l:goto_key_index]
  let l:filename = s:goto_complete_dict[l:goto_key]

  " Using find command, find folders holding python
  " files at "s:goto_complete_dict[s:filename]"
  let l:findcmd = "find */ -type f -name "
        \ . shellescape(l:filename)
        \ . " | grep -oE '^[^/]+'"
        \ . " | grep " . shellescape(a:ArgLead)
  let l:folders = system(l:findcmd)
  return split(l:folders, "\n")
endfunction

function! s:DjangoGoto(app_label, name)
  " Build filename
  if len(a:app_label) > 0
    let l:destiny = getcwd() . "/" . a:app_label . "/" . a:name . ".py"
  else
    let l:destiny = expand("%:p:h") . "/" . a:name . ".py"
  endif

  " Edit file if it exists
  if filereadable(l:destiny)
    execute "edit " . l:destiny
  else
    call s:Error("File " . l:destiny . " does not exists")
  endif
endfunction

" Same as python_cmd refactoring
let s:manage_cmd = s:python_cmd . " " . g:pony_manage_filename

function! s:DjangoManageComplete(ArgLead, CmdLine, CursorPos)
  " Check before continuing
  if !s:ManageExists()
    return []
  endif

  " Actually list commands
  let l:list_cmd = s:manage_cmd 
        \ . " help --commands"
        \ . " | grep " . shellescape(a:ArgLead)
  let l:commands = system(l:list_cmd)
  return split(l:commands, "\n")
endfunction

" Set this flag to allow Pony to display colors when
" using the manage commmands
let g:pony_display_colors = 1

function! s:DjangoManage(arguments)
  " Check before continuing
  if !s:ManageExists()
    call s:Error("File '" . g:pony_manage_filename . "' does not exists in CWD")
    return
  endif

  " Build manage command from arguments
  let l:cmd = "!"
  if !g:pony_display_colors
    " Don't display colors
    let l:cmd .= "export DJANGO_COLORS=nocolor &&"
  end
  execute l:cmd . " " . s:manage_cmd . " " . a:arguments
endfunction

" Setup DjangoGoto commands
for goto_key in s:goto_possible_keys
  execute "command! -nargs=? -complete=customlist,s:DjangoGoToComplete "
        \ . s:RealCommandName(goto_key)
        \ . " :call s:DjangoGoto('<args>', '" . goto_key . "')"
endfor

" Manage and its shortcuts
execute "command! -nargs=? -complete=customlist,s:DjangoManageComplete "
      \ . s:RealCommandName("manage")
      \ . " :call s:DjangoManage('<args>')"
" dictionary for configuration of the manage shortcuts
let s:manage_shortcuts = {
      \ "dbshell"   : "dbshell",
      \ "runserver" : "runserver",
      \ "syncdb"    : "syncdb",
      \ "shell"     : "shell"
      \ }

" Make manage shortcut commands
for pair in items(s:manage_shortcuts)
  let shortcut = pair[0]
  let shortcut_arg = pair[1]
  execute "command! -nargs=0 "
        \ . g:pony_prefix . shortcut
        \ . " :call s:DjangoManage('" . shortcut_arg . "')"
  unlet shortcut
  unlet shortcut_arg
endfor

" vim: ai et sw=2 sts=2
