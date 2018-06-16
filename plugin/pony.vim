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
if !exists('g:pony_manage_filename')
  let g:pony_manage_filename = findfile("manage.py")
endif

" function to wrap the check on this file
function! s:ManageExists()
  return filereadable(g:pony_manage_filename)
endfunction

" Script error function, preferred to echoerr
function! s:Error(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunction

" Specify command to apply to the manage.py script (default: python)
let g:pony_python_cmd = "python"

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
  " Check before continuing
  if !s:ManageExists()
    return []
  endif

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
        \ . " | sed 's/\\([^\\/]*\\)\\/" . escape(l:filename, './') . "/\\1/g'"
        \ . " | grep " . shellescape(a:ArgLead)
  let l:folders = system(l:findcmd)
  return split(l:folders, "\n")
endfunction

function! s:DjangoGoto(app_label, name)
  " Build app directory
  if len(a:app_label) > 0
    let l:real_app_label = a:app_label
    if !filereadable(l:real_app_label)
      let l:cmd = "ls -d " . l:real_app_label . "*"
      let l:app_label_candidates = split(system(l:cmd))
      if len(l:app_label_candidates) == 0
        s:Error("File " . a:app_label . " doesn't have any candidates in CWD")
        return
      endif
      let l:real_app_label = l:app_label_candidates[0]
    endif
    let l:app_dir = getcwd() . "/" . l:real_app_label
  else
    let l:app_dir = expand("%:p:h")
  endif

  " Build filename
  let l:filename = l:app_dir . "/" . s:goto_complete_dict[a:name]

  " Edit file if it exists
  if filereadable(l:filename)
    execute "edit " . l:filename
  else
    call s:Error("File " . l:filename . " does not exists")
  endif
endfunction

" Return manage cmd via a function, because g:pony_manage_filename might
" change.
function! s:manage_cmd()
  return g:pony_python_cmd . " " . g:pony_manage_filename
endfunction

function! s:DjangoManageComplete(ArgLead, CmdLine, CursorPos)
  " Check before continuing
  if !s:ManageExists()
    return []
  endif

  " Actually list commands
  let l:list_cmd = s:manage_cmd()
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
  if has("win32")
    let l:cmd .= " start /B "
  else
    if !g:pony_display_colors || has("gui_running")
      " Don't display colors
      let l:cmd .= "export DJANGO_COLORS=nocolor &&"
    endif
  endif
  execute l:cmd . " " . s:manage_cmd() . " " . a:arguments
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
