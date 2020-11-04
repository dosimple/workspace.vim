" Workspace (as in i3wm) for Vim
" --------------------------
" File:      workspace.vim
" Author:    Olzvoi Bayasgalan <me@olzvoi.dev>
" Home:      https://github.com/dosimple/workspace.vim
" Version:   0.2
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

" Open the workspace
"
" Return:   true - for workspace created new
"           false - workspace exists
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
        call s:bufdummy()
    endif
    echo WS_Line()
    return ! tabnum
endfunc

function! WS_Close(WS)
    let tabnum = a:WS ? WS_Tabnum(a:WS) : tabpagenr()
    if tabnum
        exe "tabclose " . tabnum
    endif
endfunc

function! WS_Backforth()
    if get(s:, "prev")
        call WS_Open(s:prev)
    endif
endfunc

function! WS_Empty(WS)
    let t = WS_Tabnum(a:WS)
    if tabpagewinnr(t, "$") != 1
        return v:false
    endif
    let bs = tabpagebuflist(t)
    if len(bs) > 1 || ! s:isbufdummy(bs[0])
        return v:false
    endif
    let bs = WS_Buffers(t:WS)
    if len(bs) > 1
        return v:false
    endif
    return len(bs) == 0 || s:isbufdummy(bs[0])
endfunc

function! WS_Line()
    let st = []
    for t in range(1, tabpagenr("$"))
        let tWS = gettabvar(t, "WS")
        if t == tabpagenr()
            let tWS = "<" . tWS . ">"
        elseif WS_Empty(tWS)
            continue
        endif
        call add(st, tWS)
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

function! WS_B_Move(to)
    let bnr = bufnr("%")
    let alt = bufnr("#")
    if alt == -1
        enew
        call s:bufdummy()
    else
        exe "buffer " . alt
    endif
    call WS_Open(a:to)
    exe "buffer " . bnr
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

" Initialize current tabpage, by populating
" the t:WS variable to an available workspace number.
" Expect other tabs to have beeen initialized.
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

function! s:collect_orphans()
    for b in getbufinfo()
        if b.listed && ! get(b.variables, "WS")
            call setbufvar(b.bufnr, "WS", t:WS)
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

function! s:bufadd(bnr)
    " setbufvar doesn't work on BufAdd yet.
    call setbufvar(a:bnr, "WS", t:WS)
endfunc

function! s:bufenter()
    let b:WS = t:WS
    let bnr = bufnr("%")
    if getbufvar(bnr, "WS_listed")
        call s:buflisted(bnr, 1)
    endif
    " Workaround for BufAdd
    call s:collect_orphans()
endfunc

function! s:bufdummy()
    setl nomodifiable
    setl nobuflisted
    setl noswapfile
    setl bufhidden=wipe
    "setl buftype=nofile
endfunc

" Check, whether the buffer is dummy or empty scratch
function! s:isbufdummy(b)
    let b = a:b
    if type(b) != v:t_dict
        let b = getbufinfo(b)[0]
    endif
    return ! b.changed && b.name == ""
endfunc

augroup workspace
    autocmd!
    autocmd TabEnter    * nested call s:tabenter()
    autocmd TabLeave    * nested call s:tableave()
    autocmd TabClosed   * nested call s:tabclosed()
    "autocmd BufAdd     * nested call s:bufadd(expand("<abuf>"))
    autocmd BufEnter    * nested call s:bufenter()
augroup end

command! -nargs=1 WS call WS_Open("<args>")
command! -nargs=? WSc call WS_Close("<args>")
command! -nargs=1 WSmv call WS_Rename("<args>")
command! -nargs=1 WSbmv call WS_B_Move("<args>")

function! s:init()
    for t in range(1, tabpagenr("$"))
        if ! gettabvar(t, "WS")
            call settabvar(t, "WS", t)
        endif
    endfor
endfunc

call s:init()

