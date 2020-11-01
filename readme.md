## Forked # workspace.vim

Forked following (workspace.vim) project to allow to use tab as workspaces to manage buffers similar to i3/sway

my binding are:

```vim
" create a new tab with N title or move to an exiting N tab.
nnoremap <silent> <leader>1 :WS 1<CR>
nnoremap <silent> <leader>2 :WS 2<CR>
nnoremap <silent> <leader>3 :WS 3<CR>
  .
  .
  .
```
```vim
" move current buffer to tab N
nnoremap <silent> <leader><leader>1 :WSbm 1<CR>
nnoremap <silent> <leader><leader>2 :WSbm 2<CR>
nnoremap <silent> <leader><leader>3 :WSbm 3<CR>
  .
  .
  .
```
to move between buffers use :bn :bp or any buffer plugin.

if you are using airline following setting produce best result:

```vim
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tabs = 0
let g:airline#extensions#tabline#show_tab_count = 2
```

## Additional Usage. Refer Below for more

* `:WSmb n` will move current buffer to workspace `n` (it is a number).

## Images (Workspace <1> | 2)

![screenshot_2020-11-02-020612](https://user-images.githubusercontent.com/355729/97809539-b9164b80-1cb0-11eb-9e95-7e5837c81133.png)


![screenshot_2020-11-02-020637](https://user-images.githubusercontent.com/355729/97809527-aef44d00-1cb0-11eb-908a-a692f29eafd3.png)


![screenshot_2020-11-02-020654](https://user-images.githubusercontent.com/355729/97809516-a6037b80-1cb0-11eb-8def-b6aacd4b11e3.png)


# workspace.vim

The main purpose of this plugin is to make it easier
to manage large number of buffers by letting the user
keep them grouped separately in workspaces.
Similar to i3wm workspaces holding different windows.

* Each tabpage represents a workspace.
* It's like each workspace has it's own buffer list.
* Workspaces are numbered starting with 1, like tabpages,
  but a workspace number wouldn't change as other workspaces are opened and closed.
* Third party buffer switchers should work as is.
* The `hidden` option must be on.

## Usage

* `:WS n` will switch to workspace `n` (it is a number).
* `:WSc [n]` will close current workspace or `n`.
* `:WSmv n` will rename current workspace to `n` (again a number).
* `:ls`, `:bn`, `:bp` will only operate on those buffers, which belong to the current workspace.
* Use your favorite buffer switcher.

## Useful addition to .vimrc

This example uses `Alt` key for the mappings, so it may not work in terminal.

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
imap <M-1> <Esc><M-1>
imap <M-2> <Esc><M-2>
imap <M-3> <Esc><M-3>
imap <M-4> <Esc><M-4>
imap <M-5> <Esc><M-5>
imap <M-6> <Esc><M-6>
imap <M-7> <Esc><M-7>
imap <M-8> <Esc><M-8>
imap <M-9> <Esc><M-9>
imap <M-0> <Esc><M-0>

map <silent> <M-`> :call WS_Backforth()<CR>
imap <M-`> <Esc><M-`>
```
