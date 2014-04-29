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
	    let list = getline(1, line('.') - 1)
	    call filter(list, "v:val !~# '^\\V" . g:histsearch_prefix . "'")
	    let b:histsearch_history = list
	endif
	let res = copy(b:histsearch_history)
	let base = a:base
	let base = substitute(base, '^\V' . g:histsearch_prefix , '', '')
	let base = escape(base, '"\')
	try
	    call filter(res, 'v:val =~? "' . base . '"')
	catch
	    let res = []
	endtry
	let b:histsearch_empty = empty(res)
	return res
    endif
endfun

function! histsearch#setup()
    setlocal completefunc=histsearch#complete

    autocmd! HistSearch * <buffer>
    autocmd HistSearch CursorMovedI <buffer> call histsearch#feedkeys()

    if !exists('g:histsearch_no_mappings') || !g:histsearch_no_mappings
	inoremap <buffer> <expr> <Esc> histsearch#cancel("\<Esc>")
	inoremap <buffer> <expr> <C-c> histsearch#cancel("\<C-c>")
	inoremap <buffer> <expr> <CR>  histsearch#enter("\<CR>")
	inoremap <buffer> <expr> <C-j> pumvisible() ? "\<Down>" : "\<C-j>"
	inoremap <buffer> <expr> <C-k> pumvisible() ? "\<Up>" :
	\					      histsearch#start()
	inoremap <buffer> <expr> <C-e> histsearch#end("\<C-e>")
	inoremap <buffer> <expr> * histsearch#is_active() ? ".*" : "*"
    endif
endfunction

function! histsearch#is_active()
    return getline('.') =~# '^\V' . g:histsearch_prefix
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
    if histsearch#is_active()
	let end = pumvisible() ? "\<C-e>" : ""
	return end . histsearch#end0()
    endif

    return a:fallback
endfunction

function! histsearch#enter(fallback)
    if histsearch#is_active()
	if pumvisible()
	    return "\<C-y>\<CR>"
	endif
	return histsearch#end0() . "\<CR>"
    endif

    return a:fallback
endfunction

function! histsearch#cancel(fallback)
    if histsearch#is_active()
	if pumvisible()
	    return "\<C-e>\<C-u>\<CR>"
	endif
	return "\<C-u>\<CR>"
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

let &cpo = s:cpo_save
