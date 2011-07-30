" History search plugin
" Maintainer: INAJIMA Daisuke <inajima@sopht.jp>
" License: MIT License

let s:cpo_save = &cpo
set cpo&vim

function! histsearch#complete(findstart, base)
    if a:findstart
	let b:histsearch_end = col('.')
	return 0
    else
	if !exists('b:histsearch_history')
	    call histdel(b:histsearch_mode, '^\V' . g:histsearch_prefix)
	    let b:histsearch_history = histsearch#history(b:histsearch_mode)
	endif
	let res = copy(b:histsearch_history)
	let base = a:base
	let base = substitute(base, '^\V' . g:histsearch_prefix , '', '')
	let base = substitute(base, '*', '.*', 'g')
	let base = substitute(base, '?', '.', 'g')
	let base = escape(base, '"')
	call filter(res, 'v:val =~? "' . base . '"')
	let b:histsearch_empty = empty(res)
	return res
    endif
endfun

function! histsearch#setup(mode)
    setlocal completefunc=histsearch#complete
    let b:histsearch_mode = a:mode == '?' ? '/' : a:mode

    autocmd! HistSearch * <buffer>
    autocmd HistSearch CursorMovedI <buffer> call histsearch#feedkeys()

    if !exists('g:histsearch_no_mappings') || !g:histsearch_no_mappings
	nnoremap <silent> <buffer> <Esc><Esc> :<C-u>quit<CR>
	inoremap <buffer> <expr> <CR>  histsearch#enter("\<CR>")
	inoremap <buffer> <expr> <C-j> pumvisible() ? "\<Down>" : "\<C-j>"
	inoremap <buffer> <expr> <C-k> pumvisible() ? "\<Up>" :
	\					      histsearch#start()
	inoremap <buffer> <expr> <C-e> histsearch#end("\<C-e>")
    endif
endfunction

function! histsearch#start0()
    let up = "\<C-r>=pumvisible() ? \"\\<Up>\" : ''\<CR>"
    return "\<C-x>\<C-u>\<C-p>\<C-p>\<C-n>" . up
endfunction

function! histsearch#start()
    let prefix = "\<Home>" . g:histsearch_prefix . "\<End>"
    return prefix . histsearch#start0()
endfunction

function! histsearch#end0()
    let n = strlen(g:histsearch_prefix)
    return "\<Home>" . repeat("\<Del>", n) . "\<End>"
endfunction

function! histsearch#end(fallback)
    let curline = getline('.')

    if curline =~# '^\V' . g:histsearch_prefix
	let end = pumvisible() ? "\<C-e>" : ""
	return end . histsearch#end0()
    endif

    return a:fallback
endfunction

function! histsearch#enter(fallback)
    let curline = getline('.')

    if curline =~# '^\V' . g:histsearch_prefix
	if pumvisible()
	    return "\<C-y>\<CR>"
	endif
	return histsearch#end0() . "\<CR>"
    endif

    return a:fallback
endfunction

function! histsearch#feedkeys()
    let curline = getline('.')

    if curline =~# '^\V' . g:histsearch_prefix &&
    \  (!b:histsearch_empty || b:histsearch_end != col('.'))
	call feedkeys(histsearch#start0(), "n")
    elseif curline ==# g:histsearch_prefix[:-2]
	call feedkeys("\<End>\<C-u>")
    endif
endfunction

function! histsearch#history(type)
    let histlist = []
    let histdic = {}

    for i in range(histnr(a:type), 1, -1)
	let item = histget(a:type, i)

	if item != "" && !has_key(histdic, item)
	    let histdic[item] = 1
	    call insert(histlist, item)
	endif
    endfor
    return histlist
endfunction

let &cpo = s:cpo_save
