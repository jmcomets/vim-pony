# pony.vim

Pony power for working with Django projects in Vim.

![Pony powered](http://media.djangopony.com/img/small/badge.png)

## Installation

For those using [pathogen](https://github.com/tpope/vim-pathogen),
simply copy/clone the entire repo in your ~/.vim/bundle.

Otherwise, copy `plugin/pony.vim` to your ~/.vim/plugin folder.

## Jump commands

Some basic commands are available to jump to commonly used files in Django:

- Dadmin: admin.py
- Dmodels: models.py
- Dsettings: settings.py
- Dtests: tests.py
- Durls: urls.py
- Dviews: views.py

All these *jump commands* take an optional "app" argument, and will
jump accordingly to the file in that app. Defaults to the current directory.

Example :

    :Dviews app " opens app/views.py
    :Dmodels " opens app/models.py

## Managing commands

The manage.py utility script is available via `:Dmanage`.
Note that any command involving the manage.py utility must be run
from that directory.

Shortcuts are available for a few common manage.py commands:

- Drunserver : manage.py runserver
- Dsyncdb : manage.py syncdb
- Dshell : manage.py shell
- Ddbshell : manage.py dbshell

Tip: I use `:Dr` for runserver, `:Dsy` for syncdb and `:Dsh` for shell.

## Configuration

    g:pony_prefix           prefix to all Pony's commands (default: "D")
    g:pony_display_colors   flag indicating if the manage.py should output colors (default: 1)
    g:pony_manage_filename  filename of the manage.py script (default: manage.py)
    g:pony_python_cmd       exact command to run on the manage.py script (default: python)

## Credits

- [Rainer Borene](https://github.com/rainerborene), the initial contributor
- [Jean-Marie Comets](https://github.com/jmcomets), current maintainer
