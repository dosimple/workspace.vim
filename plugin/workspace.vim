" Workspace for Vim
" --------------------------
" File:      workspace.vim
" Author:    Olzvoi Bayasgalan <me@olzvoi.dev>
" Home:      https://github.com/dosimple/workspace.vim
" Version:   0.4
" Copyright: Copyright (C) 2022 Olzvoi Bayasgalan
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
func! WS_Open(WS)
    if a:WS < 1
        throw "Workspace invalid: " .. a:WS
    endif
    let tabnum = WS_Tabnum(a:WS)
    if tabnum
        exe "tabnext " . tabnum
    else
        silent exe WS_Tabnum(a:WS, 1) . "tabnew"
        call WS_Rename(a:WS)
        call s:bufdummy(0)
    endif
    return ! tabnum
endfunc

func! WS_Close(WS)
    let tabnum = a:WS ? WS_Tabnum(a:WS) : tabpagenr()
    if tabnum > 0
        exe "tabclose " . tabnum
    endif
endfunc

func! WS_Backforth()
    call WS_Open(s:prev)
endfunc

func! s:empty(WS)
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

func! WS_Line()
    for t in range(1, tabpagenr("$"))
        let tWS = gettabvar(t, "WS")
        if t == tabpagenr()
            echon " "
            echohl PmenuSel
            echon " " tWS " "
            echohl None
            echon " "
        else
            echon " " tWS " "
        endif
    endfor
endfunc

func! WS_Rename(WS)
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
    call s:renumber(tabpagenr(), a:WS)
    call s:session_var()
    call WS_Line()
endfunc

func! s:renumber(t, n)
    let WS = gettabvar(a:t, "WS")
    if WS == a:n
        return
    endif
    if has_key(s:ws, a:n)
        throw "Workspace exists: " .. a:n
    endif
    if has_key(s:ws, WS)
        unlet s:ws[WS]
    endif
    call settabvar(a:t, "WS", a:n+0)
    let s:ws[a:n] = 1
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

" Update g:WS_Session variable.
" It is saved in session to restore workspaces.
func! s:session_var()
    if stridx(&sessionoptions, "globals") < 0 || exists("g:SessionLoad")
        return
    endif
    let sv = { "ws": [0], "bs": {} }
    for t in range(1, tabpagenr("$"))
        call add(sv.ws, gettabvar(t, "WS"))
    endfor
    for b in getbufinfo()
        let ws = s:bws(b)
        if ! empty(ws) && s:listed(b) && getbufvar(b.bufnr, "&buftype") == "" && b.name != ""
            let sv.bs[b.name] = ws
        endif
    endfor
    let g:WS_Session = string(sv)
endfunc

func! s:session_load()
    if ! exists("g:WS_Session")
        return
    endif
    exe "let sv = " .. g:WS_Session
    for t in range(tabpagenr("$"), 1, -1)
        if t != tabpagenr()
            call s:renumber(t, sv.ws[t])
        endif
    endfor
    " To accomodate existing buffers proir to loading session
    silent call WS_Rename(sv.ws[tabpagenr()])
    for fname in keys(sv.bs)
        if ! bufexists(fname)
            exe "badd " .. fnameescape(fname)
        endif
        let b = s:b(fname)
        let b.variables.WS = sv.bs[fname]
        call s:setlisted(b, s:in(t:WS, b))
    endfor
    unlet g:WS_Session
endfunc

" Get listed buffer of a workspace.
" Optionally include unlisted buffers by second argument.
func! WS_Buffers(WS, ...)
    let all = get(a:, 1, v:false)
    let bs = []
    for b in getbufinfo()
        if empty(s:bws(b)) && b.loaded
            "echo "Found orphan buffer: " . b.name . ": " . b.bufnr
            call s:add(t:WS, b)
        endif
        if s:in(a:WS, b) && (all || s:listed(b))
            call add(bs, b)
        endif
    endfor
    return bs
endfunc

func! WS_B_Move(to)
    if a:to == t:WS
        return
    endif
    let b = s:b("%")
    call s:buffer_alt_or_dummy()
    call s:add(a:to, b)
    call s:remove(t:WS, b)
    call WS_Open(a:to)
    exe "buffer " . b.bufnr
    call s:session_var()
endfunc

" Remove buffer (current or given) from workspace (current, number, or 0 for all workspaces).
" Or delete, if it is open in only one workspace.
" Return: true for success
func! WS_B_Remove(...)
    let b = s:b(get(a:, 1))
    let WS = get(a:, 2, t:WS)
    if empty(b)
        call s:warning("Buffer not found!")
        return
    endif
    let tab = tabpagenr()
    let removed = v:true
    for t in WS == 0 ? range(1, tabpagenr('$')) : [WS_Tabnum(WS)]
        if index(tabpagebuflist(t), b.bufnr) > -1
            exe 'tabmove ' .. t
            call s:buffer_alt_or_dummy(b.bufnr)
        endif
        if len(b.variables.WS) > 1
            let removed = removed && s:remove(gettabvar(t, "WS"), b)
        else
            exe "bdelete " .. b.bufnr
            return ! bufloaded(b.bufnr)
        endif
    endfor
    exe 'tabmove ' .. tab
    return removed
endfunc

func! WS_Tabnum(WS, ...)
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

func! s:warning(msg)
    echohl WarningMsg | echo a:msg | echohl None
endfunc

" Initialize current tabpage, by populating
" the t:WS variable to an available workspace number.
" Expect other tabs to have been initialized.
func! s:tabinit()
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
    call s:session_var()
    return WS
endfunc

func! s:listed(b)
    return a:b.listed || get(a:b.variables, "WS_Listed")
endfunc

func! s:setlisted(b, listed)
    call setbufvar(a:b.bufnr, "&buflisted", a:listed)
    call setbufvar(a:b.bufnr, "WS_Listed", ! a:listed)
endfunc

func! s:tabclosed()
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
            if get(b.variables, "WS_Listed")
                call s:setlisted(b, 1)
            endif
        endif
    endfor
    unlet s:ws[closed]
    call s:session_var()
endfunc

func! s:tableave()
    for b in WS_Buffers(t:WS)
        call s:setlisted(b, 0)
    endfor
    let s:prev = t:WS
endfunc

func! s:tabenter()
    let WS = t:WS
    for b in WS_Buffers(WS)
        call s:setlisted(b, 1)
    endfor
    if ! exists("g:SessionLoad")
        if s:empty(s:prev)
            call WS_Close(s:prev)
        endif
        call WS_Line()
    endif
endfunc

func! s:winenter()
    let WS = s:tabinit()
    let bnralt = bufnr("#")
    " Reset alternate buffer, if it has been moved to other workspace
    if bnralt > -1 && ! s:in(WS, bnralt)
        let @# = bufnr("%")
    endif
endfunc

" Free current window of current buffer
func! s:alt_or_dummy()
    let buf = bufnr("%")
    let alt = bufnr("#")
    if alt > 0 && alt != buf
        buffer #
    else
        bprevious
    endif
    if bufnr("%") == buf
        call s:bufdummy(1)
    endif
endfunc

" Free all windows of the buffer
func! s:buffer_alt_or_dummy(...)
    let buf = bufnr(get(a:, 1, "%"))
    let win = winnr()
    for w in range(1, winnr("$"))
        if buf == winbufnr(w)
            exe w .. "wincmd w"
            call s:alt_or_dummy()
        endif
    endfor
    exe win .. "wincmd w"
endfunc

func! s:bufenter()
    let b = s:b("%")
    if s:add(t:WS, b)
        call s:session_var()
    endif
    if get(b.variables, "WS_Listed")
        call s:setlisted(b, 1)
    endif
endfunc

func! s:bufunload(f)
    let b = s:b(a:f)
    unlet b.variables.WS
    call s:session_var()
endfunc

func! s:bufdummy(create)
    if a:create
        enew
    endif
    setl nomodifiable
    setl nobuflisted
    setl noswapfile
    setl bufhidden=wipe
    setl buftype=nofile
endfunc

" Check, whether the buffer is dummy or empty scratch
func! s:isbufdummy(b)
    let b = s:b(a:b)
    return ! b.changed && b.name == ""
endfunc

augroup workspace
    autocmd!
    autocmd TabLeave    * nested call s:tableave()
    autocmd TabClosed   * nested call s:tabclosed()
    autocmd TabEnter    * nested call s:tabenter()
    autocmd WinEnter    * nested call s:winenter()
    autocmd BufEnter    * nested call s:bufenter()
    autocmd BufUnload   * nested call s:bufunload(expand("<afile>"))
    autocmd SessionLoadPost * nested call s:session_load()
augroup end

command! -nargs=1 WS call WS_Open("<args>")
command! -nargs=? WSc call WS_Close("<args>")
command! -nargs=1 WSmv call WS_Rename("<args>")
command! -nargs=1 WSbmv call WS_B_Move("<args>")
command! -nargs=? WSbrm call WS_B_Remove("<args>")

if ! get(s:, "prev")
    for t in range(1, tabpagenr("$"))
        let s:ws[t] = 1
        call settabvar(t, "WS", t)
    endfor
    let s:prev = t:WS
endif

