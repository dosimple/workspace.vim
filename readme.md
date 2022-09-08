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

* Copy workspace.vim file to vim plugin directory.
* Enable `hidden` option.
* Add `globals` to `sessionoptions` option (for session saving/loading).

## Usage

| Command       | Description                               |
|---------------|-------------------------------------------|
| `:WS n`       | Switch to workspace `n` (it is a number). Create it, when necessary. |
| `:WSc [n]`    | Close current workspace or `n`.           |
| `:WSmv n`     | Rename current workspace to `n`. |
| `:WSbmv n`    | Move current buffer to workspace `n`.     |
| `:WSbrm [n]`  | Remove buffer from current workspace. Or delete it, if it is open in only current workspace. |

All commands try to preserve window layout, while handling buffers.

## Useful addition to .vimrc

This example uses `Alt` key for the mappings, so it may not work in some terminals.

```vim
map <silent> <M-1> :WS 1<CR>
map <silent> <M-2> :WS 2<CR>
map <silent> <M-3> :WS 3<CR>
map <silent> <M-4> :WS 4<CR>
map <silent> <M-5> :WS 5<CR>
map <silent> <M-6> :WS 6<CR>
map <silent> <M-7> :WS 7<CR>
map <silent> <M-8> :WS 8<CR>
map <silent> <M-9> :WS 9<CR>
map <silent> <M-0> :WS 10<CR>
imap <M-1> <C-O><M-1>
imap <M-2> <C-O><M-2>
imap <M-3> <C-O><M-3>
imap <M-4> <C-O><M-4>
imap <M-5> <C-O><M-5>
imap <M-6> <C-O><M-6>
imap <M-7> <C-O><M-7>
imap <M-8> <C-O><M-8>
imap <M-9> <C-O><M-9>
imap <M-0> <C-O><M-0>

" Alternate between current and previous workspaces
map <silent> <M-`> :call WS_Backforth()<CR>
imap <M-`> <C-O><M-`>

" Show info line about workspaces
map <silent> <F1> :echo WS_Line()<CR>
imap <F1> <C-O><F1>
```

