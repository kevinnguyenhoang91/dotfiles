" Faster loading (https://neovim.io/doc/user/provider.html)
if has('nvim')
  let g:python_host_skip_check = 1
  let g:python3_host_skip_check = 1
  let g:ruby_host_skip_check = 1
  if executable('python2')
    let g:python_host_prog = exepath('python2')
  endif
  if executable('python3')
    let g:python3_host_prog = exepath('python3')
    " echo exepath('python3')
  endif
  if executable('ruby')
    let g:ruby_host_prog = exepath('ruby')
    " let g:ruby_host_prog = 'rvm system do neovim-ruby-host'
  endif
endif

" Minpac
packadd minpac
let s:plugins = exists('*minpac#init')
if !s:plugins "{{{
  fun! InstallPlug() " Bootstrap plugin manager on new systems.
    exe '!git clone https://github.com/k-takata/minpac.git ~/.config/nvim/pack/minpac/opt/minpac'
  endfun
else
call minpac#init()
" minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
call minpac#add('k-takata/minpac', {'type': 'opt'})
call minpac#add('justinmk/vim-sneak')
call minpac#add('junegunn/fzf', { 'do': 'yes n \| ./install' })
call minpac#add('junegunn/fzf.vim')
call minpac#add('mhinz/vim-signify')
call minpac#add('scrooloose/nerdtree')
call minpac#add('sheerun/vim-polyglot')
call minpac#add('tomtom/tcomment_vim')
call minpac#add('tpope/vim-endwise')
call minpac#add('tpope/vim-fugitive')
call minpac#add('tpope/vim-rails')
call minpac#add('tpope/vim-repeat')
call minpac#add('tpope/vim-rhubarb')
call minpac#add('tpope/vim-surround')
call minpac#add('wellle/targets.vim')
call minpac#add('rstacruz/vim-closer')
call minpac#add('ncm2/ncm2')
call minpac#add('ncm2/ncm2-bufword')
call minpac#add('ncm2/ncm2-tagprefix')
call minpac#add('ncm2/ncm2-path')
call minpac#add('roxma/nvim-yarp')
call minpac#add('christoomey/vim-tmux-navigator')
call minpac#add('andreypopp/vim-colors-plain')
call minpac#add('w0rp/ale')
call minpac#add('rakr/vim-one')
call minpac#add('sickill/vim-monokai')
call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
endif "}}}

" Define user commands for updating/cleaning the plugins.
" Each of them loads minpac, reloads .vimrc to register the
" information of plugins, then performs the task.
command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update('', {'do': 'call minpac#status()'})
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
command! PackStatus packadd minpac | source $MYVIMRC | call minpac#status()

" General settings (see :h vim-differences)
filetype plugin indent on
set clipboard^=unnamed
set completeopt=noinsert,menuone,noselect
set copyindent
" Don't mess with 'tabstop', with 'expandtab' it isn't used.
" Instead set softtabstop=-1, then 'shiftwidth' is used.
set expandtab shiftwidth=2 softtabstop=-1
set hidden
set incsearch hlsearch ignorecase smartcase
set lazyredraw
set linebreak
set list listchars=tab:.\ ,trail:.
set matchpairs+=<:>
set nobackup
set noshowmode
set noswapfile
set scrolloff=5
set shortmess+=cW
set splitright
set tags=./tags;,tags
set termguicolors
set ttimeoutlen=0
set wildignore+=tags,*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem,*.pyc,*.swp,*~,*/.DS_Store
set wildmode=longest:full,list,full
set number relativenumber

" Safeguard
if !exists("g:syntax_on")
  syntax enable
endif

" Colorscheme
set background=dark
colorscheme monokai
hi clear VertSplit
hi VertSplit guifg=#191919
hi! link PmenuSel TermCursor
hi! link Todo Comment
hi! Search guifg=#ffffff guibg=NONE gui=underline,Bold
hi! IncSearch guifg=#ffffff guibg=NONE

" Vim Sneak
let g:sneak#label = 1
let g:sneak#use_ic_scs = 1
let g:sneak#absolute_dir = 1
map f <Plug>Sneak_s
map F <Plug>Sneak_S
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" Leader general mapping
let mapleader = ","
nnoremap <leader>w :w<cr>
nnoremap <leader>q :q<cr>
nnoremap <leader>s <c-w>w
nnoremap <leader>r :source ~/.config/nvim/init.vim<cr>
nnoremap <leader><cr> :let @/ = ""<cr>

" Navigate properly when lines are wrapped
nnoremap j gj
nnoremap k gk

" Use tab to jump between blocks, because it's easier
nnoremap <tab> %
vnoremap <tab> %

" NERDTree mapping and config
noremap <leader>n :NERDTreeToggle<CR>
noremap <leader>c :NERDTreeFind<CR>
vmap ++ <plug>NERDCommenterToggle
nmap ++ <plug>NERDCommenterToggle
let NERDTreeShowHidden = 1
let NERDTreeMinimalUI = 1
let NERDTreeHighlightCursorline = 0
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeIgnore = ['^\~$[[dir]]', '^\.o$[[file]]', '^\.pyc$[[file]]', '^\.DS_Store$[[file]]']


" Highlight currently open buffer in NERDTree
" autocmd BufEnter * call SyncTree() 

" FZF
nnoremap <leader>h :History<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>t :Files<CR>

" Ripgrep
noremap <leader>rg <esc>:Rg<space>
noremap <leader>rw <esc>:Rg <c-r><c-w>
noremap <leader>rh <esc>:Rg<up><cr>

" Vim-fugitive and vim-rhubarb
noremap <silent> gb :Gblame<CR>
noremap <silent> ghub :Gbrowse<CR>

" ESC
inoremap jk <ESC>

" Signify config
let g:signify_vcs_list = [ 'git' ]
let g:signify_realtime = 1
let g:signify_sign_show_count = 0
let g:signify_sign_change = '-'
hi! link SignifySignAdd DiffAdd
hi! link SignifySignChange DiffChange
hi! link SignifySignDelete DiffDelete

" Replace Gutentags
command! Tags !ctags -R -I EXTERN -I INIT
      \ --exclude='*.git'
      \ --exclude='*.svg'
      \ --exclude='*.hg'
      \ --exclude='bin'
      \ --exclude='docs'
      \ --exclude='build*'
      \ --exclude='.vim-src/**'
      \ --exclude='node_modules/**'
      \ --exclude='*.lock'
      \ --exclude='tags*'
      \ --exclude='venv/**'
      \ --exclude='**/site-packages/**'
      \ --exclude='data/**'
      \ --exclude='dist/**'
      \ --exclude='notebooks/**'
      \ --exclude='Notebooks/**'
      \ --exclude='*graphhopper_data/*.json'
      \ --exclude='*graphhopper/*.json'
      \ --exclude='*.json'
      \ --exclude='qgis/**' *

" Enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" Use <TAB> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" ALE config
nmap <leader>e <Plug>(ale_fix)
let g:ale_sign_error = '×'
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_set_highlights = 0
let g:ale_lint_on_text_changed = 'never'
let g:ale_linters = { 'ruby': ['rubocop'], 'javascript': ['eslint', 'prettier'] }
let g:ale_fixers = { 'ruby': ['rubocop'], 'javascript': ['prettier'] }
hi! link ALEError DiffDelete
hi! link ALEErrorSign DiffDelete
hi! link ALEWarning DiffChange
hi! link ALEWarningSign DiffChange

" Move lines
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Toggle hybrid line number
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
