" Workspace (as in i3wm) for Vim
" --------------------------
" File:      workspace.vim
" Author:    Olzvoi Bayasgalan <me@olzvoi.dev>
" Home:      https://github.com/dosimple/workspace.vim
" Version:   0.3
" Copyright: Copyright (C) 2021 Olzvoi Bayasgalan
" License:   VIM License
"
if exists('loaded_workspace')
    finish
endif
let loaded_workspace = 1

if v:version < 700
    finish
endif

if ! has_key(s:, 'ws')
    let s:ws = {}
end

" Open the workspace
"
" Return:   1   for workspace created new
"           0   workspace exists
"           -1  invalid workspace
function! WS_Open(WS)
    if a:WS < 1
        call s:warning("Workspace invalid.")
        return -1
    endif
    let tabnum = WS_Tabnum(a:WS)
    if tabnum
        exe "tabnext " . tabnum
    else
        exe WS_Tabnum(a:WS, 1) . "tabnew"
        call WS_Rename(a:WS)
        call s:bufdummy(0)
    endif
    echo WS_Line()
    return ! tabnum
endfunc

function! WS_Close(WS)
    let tabnum = a:WS ? WS_Tabnum(a:WS) : tabpagenr()
    if tabnum > 0
        exe "tabclose " . tabnum
    endif
endfunc

function! WS_Backforth()
    call WS_Open(s:prev)
endfunc

function! s:empty(WS)
    let t = WS_Tabnum(a:WS)
    if tabpagewinnr(t, "$") != 1
        return v:false
    endif
    let bs = tabpagebuflist(t)
    if len(bs) > 1 || ! s:isbufdummy(bs[0])
        return v:false
    endif
    let bs = WS_Buffers(a:WS)
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
    for b in WS_Buffers(t:WS, v:true)
        call s:remove(t:WS, b)
        call s:add(a:WS, b)
    endfor
    unlet s:ws[t:WS]
    let t:WS = a:WS+0
    let s:ws[t:WS] = 1
endfunc

func! s:b(b)
    let b = a:b
    if type(b) != v:t_dict
        let b = get(getbufinfo(b), 0)
    endif
    if ! empty(b) && ! has_key(b.variables, "WS")
        let b.variables.WS = []
    endif
    return b
endfunc

func! s:bws(b)
    return s:b(a:b).variables.WS
endfunc

func! s:in(WS, b)
    return index(s:bws(a:b), a:WS+0) >= 0
endfunc

func! s:add(WS, b)
    let ws = s:bws(a:b)
    if index(ws, a:WS+0) < 0
        call add(ws, a:WS+0)
        return 1
    endif
endfunc

func! s:remove(WS, b)
    let ws = s:bws(a:b)
    let i = index(ws, a:WS+0)
    if i >= 0
        call remove(ws, i)
        return 1
    endif
endfunc

" Get listed buffer of a workspace.
" Optionally include unlisted buffers by second argument.
function! WS_Buffers(WS, ...)
    let all = get(a:, 1, v:false)
    let bs = []
    for b in getbufinfo()
        let ws = s:bws(b)
        if empty(ws) && b.loaded
            "echo "Found orphan buffer: " . b.name . ": " . b.bufnr
            call add(ws, t:WS+0)
        endif
        if index(ws, a:WS+0) >= 0 && (all || b.listed || get(b.variables, "WS_listed"))
            call add(bs, b)
        endif
    endfor
    return bs
endfunc

function! WS_B_Move(to)
    if a:to == t:WS
        return
    endif
    let b = s:b("%")
    call s:buffer_alt_or_dummy()
    call s:add(a:to, b)
    call s:remove(t:WS, b)
    call WS_Open(a:to)
    exe "buffer " . b.bufnr
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
    if get(t:, "WS")
        return t:WS
    endif
    let tabnum = tabpagenr()
    let WSp = gettabvar(tabnum - 1, "WS", 0)
    let WSn = gettabvar(tabnum + 1, "WS", 0)
    let WS = 0
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
    if ! WS || get(s:ws, WS)
        throw "Workspace invalid or exists: " . WS
    endif
    let t:WS = WS
    let s:ws[WS] = 1
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
    let closed = 0
    for i in keys(s:ws)
        if ! WS_Tabnum(i)
            let closed = i
            break
        end
    endfor
    if ! closed
        throw "Closed workspace not found!"
    endif
    for b in getbufinfo()
        if s:remove(closed, b) && empty(s:bws(b))
            call s:add(t:WS, b)
            if get(b.variables, "WS_listed")
                call s:buflisted(b.bufnr, 1)
            endif
        endif
    endfor
    unlet s:ws[closed]
endfunc

function! s:tableave()
    for b in WS_Buffers(t:WS)
        call s:buflisted(b.bufnr, 0)
    endfor
    let s:prev = t:WS
endfunc

function! s:winenter()
    let WS = s:tabinit()
    " Are we switching workspace?
    if WS != s:prev
        for b in WS_Buffers(WS)
            call s:buflisted(b.bufnr, 1)
        endfor
        if s:empty(s:prev)
            call WS_Close(s:prev)
        endif
    endif
    let bnralt = bufnr("#")
    " Reset alternate buffer, if it has been moved to other workspace
    if bnralt > -1 && ! s:in(WS, bnralt)
        let @# = bufnr("%")
    endif
endfunc

function! s:buffer_alt_or_dummy()
    let alt = bufnr("#")
    if alt > -1 && alt != bufnr("%")
        buffer #
    else
        call s:bufdummy(1)
    endif
endfunc

function! s:bufenter()
    let b = s:b("%")
    " let ws = b.variables.WS
    if v:false " && len(ws) && index(ws, t:WS) < 0
        " TODO: Update this old and deactivated code
        " Disassociate the buffer from the windows of previous workspace
        let tabprev = WS_Tabnum(bWS)
        let winid = win_getid()
        for wid in win_findbuf(b.bufnr)
            if tabprev == win_id2tabwin(wid)[0]
                call win_gotoid(wid)
                call s:buffer_alt_or_dummy()
            endif
        endfor
        call win_gotoid(winid)
    endif
    call s:add(t:WS, b)
    if get(b.variables, "WS_listed")
        call s:buflisted(b.bufnr, 1)
    endif
endfunc

function! s:bufdummy(create)
    if a:create
        enew
    endif
    setl nomodifiable
    setl nobuflisted
    setl noswapfile
    setl bufhidden=wipe
    "setl buftype=nofile
endfunc

" Check, whether the buffer is dummy or empty scratch
function! s:isbufdummy(b)
    let b = s:b(a:b)
    return ! b.changed && b.name == ""
endfunc

augroup workspace
    autocmd!
    autocmd TabLeave    * nested call s:tableave()
    autocmd TabClosed   * nested call s:tabclosed()
    autocmd WinEnter    * nested call s:winenter()
    autocmd BufEnter    * nested call s:bufenter()
augroup end

command! -nargs=1 WS call WS_Open("<args>")
command! -nargs=? WSc call WS_Close("<args>")
command! -nargs=1 WSmv call WS_Rename("<args>")
command! -nargs=1 WSbmv call WS_B_Move("<args>")

if ! get(s:, "prev")
    for t in range(1, tabpagenr("$"))
        let s:ws[t] = 1
        call settabvar(t, "WS", t)
    endfor
    let s:prev = t:WS
endif

