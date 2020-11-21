## Forked # workspace.vim

Forked following (workspace.vim) project. It allow to use tabs as workspaces to manage buffers similar to i3/sway.

## For updating

Please clean and reinstall from repository (last change: 2020-11-09 : airline-intergration)

## Changes compare to original

- Can move buffers between tabs
- :e, C-^, C-0, gd, gf, marks will try to seek buffer last tab and window
- Closing tab now move old buffer to previous left pos tab,
- Empty workspace (tabs) are actually removed
- :bd should work fine
- Also check original fork bcz he is progressing too =D

## My bindings and .vimrc

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
nnoremap <silent> <leader><leader>1 :WSbmv 1<CR>
nnoremap <silent> <leader><leader>2 :WSbmv 2<CR>
nnoremap <silent> <leader><leader>3 :WSbmv 3<CR>
  .
  .
  .
```

To move between buffers use :bn :bp or any buffer plugin. If deleting buffers ever randomly close parent tabs, please use moll/vim-bbye or similar plugins to delete buffers. Just like i3/sway I do not think you should use WSc (close current workspace/tab) bcz empty workspaces will close automatically now.

## Airline integration

```vim
" a non-offecial airline intergration, see screenshot below
let g:workspace#vim#airline#enable = 1
.
.
.
call plug#begin('~/.vim/plugged')
Plug 'ahmadie/workspace.vim'
Plug 'vim-airline/vim-airline'
call plug#end()
.
.
.
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tabs = 0
let g:airline#extensions#tabline#show_tab_count = 0
```

## Known Issue: Tabs & buffers are not Restored from Session.

If you are using Startfiy (or any session managmenet) you will notice that only last opened tab's buffers will be restored next time you read a session. The problem is that this plugin will actually &bufflisted=false buffer from other tabs and nvim will not save them to session file. To solve the problem use :tabo just before leaving nvim to clean all tabs and restore all buffers to &bufferlisted=true. A temporarly solution please use following:

```vim
" if you are using sessoin (ex. startify) close all tabs before exist,
" otherwise opened buffers are not restored.
augroup closealltabs
  autocmd!
  autocmd VimLeavePre * nested :tabo
augroup END
```

## Additional Usage. Refer Below for more

- `:WSmbv n` will move current buffer to workspace `n` (it is a number).

## Images (Workspace <1> | 2)

![screenshot_2020-11-09-142417](https://user-images.githubusercontent.com/355729/98503223-536d2500-2297-11eb-931b-5dcfd694cbaf.png)


![screenshot_2020-11-07-162650](https://user-images.githubusercontent.com/355729/98434787-1decfe00-2116-11eb-9315-7efe9b497999.png)

![screenshot_2020-11-02-020637](https://user-images.githubusercontent.com/355729/97809527-aef44d00-1cb0-11eb-908a-a692f29eafd3.png)

![screenshot_2020-11-02-020654](https://user-images.githubusercontent.com/355729/97809516-a6037b80-1cb0-11eb-8def-b6aacd4b11e3.png)

# workspace.vim (original Readme)

The main purpose of this plugin is to make it easier
to manage large number of buffers by letting the user
keep them grouped separately in workspaces.
Similar to i3wm workspaces holding different windows.

- Each tabpage represents a workspace.
- It's like each workspace has it's own buffer list.
- Workspaces are numbered starting with 1, like tabpages,
  but a workspace number wouldn't change as other workspaces are opened and closed.
- Third party buffer switchers should work as is.
- The `hidden` option must be on.

## Usage

- `:WS n` will switch to workspace `n` (it is a number).
- `:WSc [n]` will close current workspace or `n`.
- `:WSmv n` will rename current workspace to `n` (again a number).
- `:ls`, `:bn`, `:bp` will only operate on those buffers, which belong to the current workspace.
- Use your favorite buffer switcher.

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
