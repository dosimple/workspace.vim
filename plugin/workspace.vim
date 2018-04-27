" Workspace (as in i3wm) for Vim
" --------------------------
" File:      workspace.vim
" Author:    Olzvoi Bayasgalan <olzvoi@gmail.com>
" Home:      https://github.com/dosimple/workspace.vim
" Version:   0.1
" Copyright: Copyright (C) 2018 Olzvoi Bayasgalan
" License:   VIM License
"
if exists('loaded_workspace')
    finish
endif
let loaded_workspace = 1

if v:version < 700
    finish
endif

function! WS_Open(WS)
    if a:WS < 1
        call s:warning("Workspace invalid.")
        return
    endif
    let tabnum = WS_Tabnum(a:WS)
    if tabnum
        exe "tabnext " . tabnum
    else
        exe WS_Tabnum(a:WS, 1) . "tabnew"
        call WS_Rename(a:WS)
    endif
    echo WS_Line()
endfunc

function! WS_Backforth()
    if get(s:, "prev")
        call WS_Open(s:prev)
    endif
endfunc

function! WS_Line()
    let st = []
    for t in range(1, tabpagenr("$"))
        let tWS = gettabvar(t, "WS")
        if t == tabpagenr()
            call add(st, "<".tWS.">")
        else
            call add(st, tWS)
        endif
    endfor
    return " " . join(st, " | ")
endfunc

function! WS_Rename(WS)
    if a:WS == t:WS
        return
    endif
    if a:WS < 1 || WS_Tabnum(a:WS)
        call s:warning("Workspace invalid or exists.")
        return
    endif
    exe "tabmove " . WS_Tabnum(a:WS, 1)
    for b in WS_Buffers(t:WS)
        call setbufvar(b.bufnr, "WS", a:WS)
    endfor
    let t:WS = a:WS
endfunc

function! WS_Buffers(WS)
    let bs = []
    for b in getbufinfo()
        if get(b.variables, "WS") == a:WS
            call add(bs, b)
        endif
    endfor
    return bs
endfunc

function! WS_Tabnum(WS, ...)
    let near = get(a:, 1, 0)
    for t in range(1, tabpagenr("$"))
        let tWS = gettabvar(t, "WS")
        if a:WS == tWS
            return t
        elseif a:WS < tWS
            if near
                return t - 1
            else
                return 0
            endif
        endif
    endfor
    if near
        return tabpagenr("$")
    endif
endfunc

function! s:warning(msg)
    echohl WarningMsg | echo a:msg | echohl None
endfunc

" Initialize the tabpage populating
" the t:WS variable to an available workspace number.
" Expect other tabs to habe beeen initialized.
function! s:tabinit()
    let tabnum = tabpagenr()
    let WSp = gettabvar(tabnum - 1, "WS", 0)
    let WSn = gettabvar(tabnum + 1, "WS")
    let WS = ""
    if ! WSn || WSn - WSp > 1
        let WS = WSp + 1
    endif
    if ! WS && WSn
        for t in range(tabnum + 1, tabpagenr("$"))
            let WSp = WSn
            let WSn = gettabvar(t + 1, "WS")
            if ! WSn || WSn - WSp > 1
                let WS = WSp + 1
                break
            endif
        endfor
        exe 'tabmove ' . t
    endif
    let t:WS = WS
    return WS
endfunc

function! s:buflisted(bufnum, listed)
    if a:listed
        call setbufvar(a:bufnum, "WS_listed", "")
        call setbufvar(a:bufnum, "&buflisted", 1)
    else
        call setbufvar(a:bufnum, "WS_listed", 1)
        call setbufvar(a:bufnum, "&buflisted", 0)
    endif
endfunc

function! s:tabclosed()
    for b in getbufinfo()
        let WS = get(b.variables, "WS")
        if WS && ! WS_Tabnum(WS)
            if get(b.variables, "WS_listed")
                call s:buflisted(b.bufnr, 1)
            endif
            call setbufvar(b.bufnr, "WS", "")
        endif
    endfor
endfunc

function! s:tableave()
    let s:prev = t:WS
    for b in WS_Buffers(t:WS)
        if b.listed
            call s:buflisted(b.bufnr, 0)
        endif
    endfor
endfunc

function! s:tabenter()
    if ! get(t:, "WS")
        call s:tabinit()
    endif
    for b in WS_Buffers(t:WS)
        if get(b.variables, "WS_listed")
            call s:buflisted(b.bufnr, 1)
        endif
    endfor
endfunc

function! s:bufenter()
    let b:WS = t:WS
    if get(b:, "WS_listed")
        call s:buflisted(bufnr("%"), 1)
    endif
endfunc

augroup workspace
    autocmd!
    autocmd TabEnter * nested call s:tabenter()
    autocmd TabLeave * nested call s:tableave()
    autocmd TabClosed * nested call s:tabclosed()
    autocmd BufEnter * nested call s:bufenter()
augroup end

command! -nargs=1 WS call WS_Open("<args>")
command! -nargs=1 WSmv call WS_Rename("<args>")

function! s:init()
    for t in range(1, tabpagenr("$"))
        if ! gettabvar(t, "WS")
            call settabvar(t, "WS", t)
        endif
    endfor
endfunc

call s:init()

