# workspace.vim

**This plugin gives each tabpage it's own buffer list.**

The idea is to make it easier
to manage large number of buffers by keeping
them grouped separately in workspaces.

* Each tabpage represents a workspace with it's own buffer list.
* Workspaces are numbered starting with 1, like tabpages,
  but their numbers remain static as they are opened and closed
  — don't conflate these two sets of numbers.
* `:ls`, `:bn`, `:bp` will use buffers from current workspace.
  Third party buffer switchers should work as is.

## Installation

* Copy `workspace.vim` file to vim plugin directory.
* Enable `hidden` option.
* Add `globals` to `sessionoptions` option (for session saving/loading).
* See bellow for sample vimrc snippet.

## Usage

| Command       | Description                               |
|---------------|-------------------------------------------|
| `:WS n`       | Switch to workspace `n` (it is a number). Create it, when necessary. |
| `:WSc [n]`    | Close current workspace or `n`.           |
| `:WSmv n`     | Rename current workspace to `n`. |
| `:WSbmv n`    | Move current buffer to workspace `n`.     |
| `:WSbrm [n]`  | Remove buffer from current workspace. Or delete it, if it is open in only current workspace. |

All commands try to preserve window layout, while handling buffers.

## Updates to vimrc

Sample snippet for vimrc to setup options and mappings:

```vim
" Plugin needs these options
set hidden
set sessionoptions+=globals

" Switch among workspaces 1 through 10
map <silent> <leader>1 :WS 1<CR>
map <silent> <leader>2 :WS 2<CR>
map <silent> <leader>3 :WS 3<CR>
map <silent> <leader>4 :WS 4<CR>
map <silent> <leader>5 :WS 5<CR>
map <silent> <leader>6 :WS 6<CR>
map <silent> <leader>7 :WS 7<CR>
map <silent> <leader>8 :WS 8<CR>
map <silent> <leader>9 :WS 9<CR>
map <silent> <leader>0 :WS 10<CR>

" Alternate between current and previous workspaces
map <silent> <leader>` :call WS_Backforth()<CR>

" Show info line about workspaces
map <silent> <leader><space> :call WS_Line()<CR>
```

