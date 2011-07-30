" History search plugin
" Maintainer: INAJIMA Daisuke <inajima@sopht.jp>
" Version: 0.1
" License: MIT License

if exists("g:loaded_histsearch")
    finish
endif
let g:loaded_histsearch = 1

let s:cpo_save = &cpo
set cpo&vim

augroup HistSearch
    autocmd!
    autocmd CmdWinEnter [:/\?] call histsearch#setup(expand('<afile>'))
augroup END

nnoremap <script> <expr> <Plug>(histsearch-command)
\			 'q:i' . histsearch#start()
nnoremap <script> <expr> <Plug>(histsearch-search-forward)
\			 'q/i' . histsearch#start()
nnoremap <script> <expr> <Plug>(histsearch-search-backward)
\			 'q?i' . histsearch#start()

if !exists('g:histsearch_no_mappings') || !g:histsearch_no_mappings
    if !hasmapto('<Plug>(histsearch-command)')
	nmap q; <Plug>(histsearch-command)
    endif
    if !hasmapto('<Plug>(histsearch-search-forward)')
	nmap q' <Plug>(histsearch-search-forward)
    endif
    if !hasmapto('<Plug>(histsearch-search-backward)')
	nmap q" <Plug>(histsearch-search-backward)
    endif
endif

if !exists('g:histsearch_prefix')
    let g:histsearch_prefix = "(*history-search*)"
endif

let &cpo = s:cpo_save
