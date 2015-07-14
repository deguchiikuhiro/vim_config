" neobundleの処理
let s:noplugin = 0
let s:bundle_root = expand(g:CFGHOME . '/bundle')
let s:neobundle_root = s:bundle_root . '/neobundle.vim'
if !isdirectory(s:neobundle_root) || v:version < 702
    " NeoBundleが存在しない、もしくはVimのバージョンが古い場合はプラグインを一切
    " 読み込まない
    let s:noplugin = 1
else
    " NeoBundleを'runtimepath'に追加し初期化を行う
    if has('vim_starting')
        execute "set runtimepath+=" . s:neobundle_root
    endif

    call neobundle#begin(s:bundle_root)
    " NeoBundle自身をNeoBundleで管理させる
    NeoBundleFetch 'Shougo/neobundle.vim'

    " 非同期通信を可能にする
    " 'build'が指定されているのでインストール時に自動的に
    " 指定されたコマンドが実行され vimproc がコンパイルされる
    NeoBundle "Shougo/vimproc", {
        \ "build": {
            \ "windows"   : "make -f make_mingw32.mak",
            \ "cygwin"    : "make -f make_cygwin.mak",
            \ "mac"       : "make -f make_mac.mak",
            \ "unix"      : "make -f make_unix.mak",
        \ }
    \ }

    NeoBundle "vim-jp/vimdoc-ja"
    set helplang=ja,en

    NeoBundleLazy "Shougo/unite.vim", {
        \ "autoload": {
            \ "commands": ["Unite", "UniteWithBufferDir"]
        \ }
    \ }
    let s:hooks_unite = neobundle#get_hooks("unite.vim")
    function! s:hooks_unite.on_source(bundle)
        " start unite in insert mode
        let g:unite_enable_start_insert = 1
        " use vimfiler to open directory
        call unite#custom_default_action("source/bookmark/directory", "vimfiler")
        call unite#custom_default_action("directory", "vimfiler")
        call unite#custom_default_action("directory_mru", "vimfiler")
        autocmd MyAutoCmd FileType unite call s:unite_settings()
        function! s:unite_settings()
            imap <buffer> <Esc><Esc> <Plug>(unite_exit)
            nmap <buffer> <Esc> <Plug>(unite_exit)
            nmap <buffer> <C-n> <Plug>(unite_select_next_line)
            nmap <buffer> <C-p> <Plug>(unite_select_previous_line)
        endfunction
    endfunction

    NeoBundle "Shougo/neomru.vim"
    NeoBundleLazy "Shougo/unite-help", {
        \ "autoload": {
            \ "unite_sources" : "help"
        \ }
    \ }
    NeoBundleLazy 'Shougo/unite-outline', {
        \ "autoload": {
            \ "unite_sources": "outline",
        \ }
    \ }
    nnoremap [unite] <Nop>
    nmap U [unite]
    nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
    nnoremap <silent> [unite]h :<C-u>Unite help<CR>
    nnoremap <silent> [unite]p :<C-u>Unite file_rec/async:!<CR>
    nnoremap <silent> [unite]s :<C-u>Unite source<CR>
    nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
    nnoremap <silent> [unite]r :<C-u>Unite register<CR>
    nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
    nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>
    nnoremap <silent> [unite]o :<C-u>Unite outline<CR>
    nnoremap <silent> [unite]t :<C-u>Unite tab<CR>
    nnoremap <silent> [unite]w :<C-u>Unite window<CR>

    NeoBundleLazy "Shougo/vimfiler", {
        \ "depends": ["Shougo/unite.vim"],
        \ "autoload": {
            \ "commands": ["VimFilerTab", "VimFiler", "VimFilerExplorer"],
            \ "mappings": ['<Plug>(vimfiler_switch)'],
            \ "explorer": 1,
        \ }
    \ }

    let s:hooks_vimfiler = neobundle#get_hooks("vimfiler")
    function! s:hooks_vimfiler.on_source(bundle)
        let g:vimfiler_as_default_explorer = 1
        let g:vimfiler_enable_auto_cd = 1
    endfunction

    nnoremap <Leader>f :VimFilerExplorer<CR>
    " close vimfiler automatically when there are only vimfiler open
    autocmd MyAutoCmd BufEnter * if (winnr('$') == 1 && &filetype ==# 'vimfiler') | q | endif

    " カッコ補間
"    NeoBundle 'tpope/vim-surround'
"    NeoBundle 'vim-scripts/Align'
    " ペースト履歴
"    NeoBundle 'vim-scripts/YankRing.vim'

    " テキスト補間関連
    " if has('lua') && v:version > 703 && has('patch825') 2013-07-03 14:30 > から >= に修正
    " if has('lua') && v:version >= 703 && has('patch825') 2013-07-08 10:00 必要バージョンが885にアップデートされていました
    if has('lua') && v:version >= 703 && has('patch885')
        NeoBundleLazy "Shougo/neocomplete.vim", {
            \ "autoload": {
                \ "insert": 1,
            \ }
        \ }
        " 2013-07-03 14:30 NeoComplCacheに合わせた
        let g:neocomplete#enable_at_startup = 1
        let s:hooks = neobundle#get_hooks("neocomplete.vim")
        function! s:hooks.on_source(bundle)
            let g:acp_enableAtStartup = 0
            let g:neocomplet#enable_smart_case = 1
            " NeoCompleteを有効化
            " NeoCompleteEnable
        endfunction
    else
        NeoBundleLazy "Shougo/neocomplcache.vim", {
            \ "autoload": {
                \ "insert": 1,
            \ }
        \ }
        " 2013-07-03 14:30 原因不明だがNeoComplCacheEnableコマンドが見つからないので変更
        let g:neocomplcache_enable_at_startup = 1
        let s:hooks = neobundle#get_hooks("neocomplcache.vim")
        function! s:hooks.on_source(bundle)
            let g:acp_enableAtStartup = 0
            let g:neocomplcache_enable_smart_case = 1
            " NeoComplCacheを有効化
            " NeoComplCacheEnable 
        endfunction
    endif

    NeoBundleLazy "Shougo/neosnippet.vim", {
        \ "depends": ["glidenote/serverspec-snippets","honza/vim-snippets"],
        \ "autoload": {
            \   "insert": 1,
        \ }
    \ }
    let s:hooks_neosnippet = neobundle#get_hooks("neosnippet.vim")
    function! s:hooks_neosnippet.on_source(bundle)
        " Plugin key-mappings.
        imap <C-k>     <Plug>(neosnippet_expand_or_jump)
        smap <C-k>     <Plug>(neosnippet_expand_or_jump)
        xmap <C-k>     <Plug>(neosnippet_expand_target)
        " SuperTab like snippets behavior.
        imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
        \ "\<Plug>(neosnippet_expand_or_jump)"
        \: pumvisible() ? "\<C-n>" : "\<TAB>"
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
        \ "\<Plug>(neosnippet_expand_or_jump)"
        \: "\<TAB>"
        " For snippet_complete marker.
        if has('conceal')
            set conceallevel=2 concealcursor=i
        endif
        " Enable snipMate compatibility feature.
        let g:neosnippet#enable_snipmate_compatibility = 1
        " Tell Neosnippet about the other snippets
        let g:neosnippet#snippets_directory = [
            \s:bundle_root . '/serverspec-snippets',
            \s:bundle_root . '/vim-snippets/snippets'
        \]
    endfunction
    NeoBundle 'Shougo/neosnippet-snippets'
"    NeoBundle 'glidenote/serverspec-snippets'

    " インデント関連
    NeoBundle "nathanaelkane/vim-indent-guides"
    
    " アンドゥ関連
    NeoBundleLazy "sjl/gundo.vim", {
        \ "autoload": {
            \ "commands": ['GundoToggle'],
        \}
    \}
    nnoremap <Leader>u :GundoToggle<CR>

    " shell関連
    NeoBundle "Shougo/vimshell.vim"
    NeoBundleLazy "thinca/vim-quickrun", {
        \ "autoload": {
            \ "mappings": [['nxo', '<Plug>(quickrun)']]
        \ }
    \ }
    nmap <Leader>r <Plug>(quickrun)
    let s:hooks = neobundle#get_hooks("vim-quickrun")
    function! s:hooks.on_source(bundle)
        let g:quickrun_config = {
            \ "*": {"runner": "remote/vimproc"},
        \ }
    endfunction

    " ctag関連
    NeoBundleLazy 'majutsushi/tagbar', {
        \ "autload": {
            \ "commands": ["TagbarToggle"],
        \ },
        \ "build": {
            \ "mac": "brew install ctags",
        \ }
    \ }
    nmap <Leader>t :TagbarToggle<CR>

    NeoBundle "scrooloose/syntastic"
    let g:syntastic_python_checkers = ['flake8']
    let g:syntastic_enable_signs=1
    let g:syntastic_auto_loc_list=2

    "Markdown関連
    NeoBundle 'plasticboy/vim-markdown'
    NeoBundle 'kannokanno/previm'
    NeoBundle 'tyru/open-browser.vim'
    au BufRead,BufNewFile *.md set filetype=markdown

"
    " Python関連
"    " Djangoを正しくVimで読み込めるようにする
"    NeoBundleLazy "lambdalisue/vim-django-support", {
"          \ "autoload": {
"          \   "filetypes": ["python", "python3", "djangohtml"]
"          \ }}
    " Vimで正しくvirtualenvを処理できるようにする
"    NeoBundleLazy "jmcantrell/vim-virtualenv", {
"          \ "autoload": {
"          \   "filetypes": ["python", "python3", "djangohtml"]
"          \ }}
"
"    NeoBundleLazy "davidhalter/jedi-vim", {
"          \ "autoload": {
"          \   "filetypes": ["python", "python3", "djangohtml"],
"          \ },
"          \ "build": {
"          \   "mac": "pip install jedi",
"          \   "unix": "pip install jedi",
"          \ }}
"    let s:hooks = neobundle#get_hooks("jedi-vim")
"    function! s:hooks.on_source(bundle)
"      " jediにvimの設定を任せると'completeopt+=preview'するので
"      " 自動設定機能をOFFにし手動で設定を行う
"      let g:jedi#auto_vim_configuration = 0
"      " 補完の最初の項目が選択された状態だと使いにくいためオフにする
"      let g:jedi#popup_select_first = 0
"      " quickrunと被るため大文字に変更
"      let g:jedi#rename_command = '<Leader>R'
"      " gundoと被るため大文字に変更 (2013-06-24 10:00 追記）
"      "let g:jedi#goto_command = '<Leader>G'
"    endfunction

    "ドキュメント変換
"    NeoBundleLazy "vim-pandoc/vim-pandoc", {
"        \ "autoload": {
"            \ "filetypes": ["text", "pandoc", "markdown", "rst", "textile"],
"        \ }
"    \ }
"    NeoBundleLazy "vim-pandoc/vim-pandoc-syntax", {
"        \ "autoload": {
"            \ "filetypes": ["text", "pandoc", "markdown", "rst", "textile"],
"        \ }
"    \ }

    call neobundle#end()

    " ファイルタイププラグインおよびインデントを有効化
    " これはNeoBundleによる処理が終了したあとに呼ばなければならない
    filetype plugin indent on

    " インストールされていないプラグインのチェックおよびダウンロード
    NeoBundleCheck
endif

