set nocompatible               " be iMproved
filetype off                   " required!

" vim-plug
call plug#begin('~/.vim/plugged')

" Functionality
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'wincent/Command-T'
Plug 'tmhedberg/matchit'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-ragtag'
Plug 'tpope/vim-fugitive'
Plug 'godlygeek/tabular'
Plug 'tomtom/tcomment_vim'
Plug 'scrooloose/syntastic'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'lambdalisue/battery.vim'

" Language support
Plug 'vim-ruby/vim-ruby'
Plug 'lunaru/vim-less'
Plug 'wakatime/vim-wakatime'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'jparise/vim-graphql'
Plug 'udalov/kotlin-vim'
Plug 'posva/vim-vue'
Plug 'styled-components/vim-styled-components'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'peitalin/vim-jsx-typescript'
Plug 'jxnblk/vim-mdx-js'
Plug 'prisma/vim-prisma'

" Themes
Plug 'noahfrederick/vim-noctu'
Plug 'goatslacker/mango.vim'
Plug 'tpope/vim-vividchalk'
Plug 'nanotech/jellybeans.vim'
Plug 'tomasiser/vim-code-dark'
Plug 'sonph/onehalf'
Plug 'chr4/jellygrass.vim'
Plug 'yuttie/hydrangea-vim'
Plug 'junegunn/seoul256.vim'

call plug#end()

filetype plugin indent on
syntax on

set shortmess=I

set t_Co=256
if !has('gui_running') && &term =~# 'xterm'
  set term=xterm-256color
endif
set background=dark
let g:seoul256_background = 233

set nu

let mapleader="\\"
set timeoutlen=250
set history=256

set nowrap

set tags=./tags,tags;$HOME

" edit .vimrc
nmap <silent> <leader>ev :vsplit $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" Backup
set nowritebackup
set nobackup
set directory=/tmp// " prepend(^=) $HOME/.tmp/ to default path; use full path as backup filename(//)

" TSX/JSX scan fixes
autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

" Buffers
set autoread
set hidden

" Search
set hlsearch
set ignorecase
set smartcase
set incsearch
map <Space> :set hlsearch!<cr>

" Completion
set showmatch
set wildmenu

" Splits
set splitbelow
set splitright

" Indentation and Tab handling
set smarttab
set expandtab
set autoindent
set shiftwidth=2
set tabstop=2
set autoindent smartindent

" Remove the crutch of arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Backspace
set backspace=indent,eol,start

" Tab bar
set showtabline=2

" Status Line
set laststatus=2
set statusline=%m                            " Modified Flag
set statusline+=%r                           " Readonly Flag
set statusline+=\                            " Space
set statusline+=%<                           " Truncate on the left side of text if too long
set statusline+=%t                           " File name (Tail)
set statusline+=%=                           " Right Align
set statusline+=%{ShowSpell()}               " Show whether or not spell is currently on
set statusline+=%{ShowWrap()}                " Show whether or not wrap is currently on
set statusline+=%w                           " Preview window flag
set statusline+=%h                           " Help buffer flag
set statusline+=%y                           " Type of file
set statusline+=\                            " Space
set statusline+=(%l/%L,\ %c)                 " Current position and line count
set statusline+=\                            " Space
set statusline+=%P                           " Percent
set statusline+=\                            " Space for padding on right side

function! ShowWrap()
  if &wrap
    return "[wrap]"
  else
    return ""
endfunction

function! ShowSpell()
  if &spell
    return "[spell]"
  else
    return ""
endfunction

" colors
highlight CursorLine cterm=NONE ctermbg=0
highlight StatusLine term=reverse ctermfg=65 ctermbg=255 guifg=#FFFFFF guibg=#005f5f
highlight StatusLineNC cterm=NONE ctermfg=250 ctermbg=239
highlight TabLineFill ctermfg=239
highlight LineNr ctermfg=65
highlight Comment cterm=italic
highlight Constant cterm=italic
highlight Special cterm=italic
set cursorline!

" whitespace
match ErrorMsg '\s\+$'
nnoremap <silent> <leader>rw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>:retab<CR>

" CoC Settings
" " GoTo code navigation.
nmap <silent> gd :call CocAction('jumpDefinition', 'vsplit')<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
let g:coc_global_extensions = ['coc-tsserver']

if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif

inoremap <silent><expr> <c-@> coc#refresh()

" FZF mapping
nnoremap <C-p> :GFiles<Cr>
nnoremap <silent><leader>l :Buffers<CR>

" command-t settings
let g:CommandTMaxHeight=20
let g:CommandTMatchWindowReverse=1
let g:CommandTAcceptSelectionSplitMap=['<C-s>', '<C-CR>']
let g:CommandTCancelMap=['<C-c>', '<Esc>']
noremap <leader>f :CommandTFlush<CR>

if has("autocmd")
  " jQuery settings
  au BufRead,BufNewFile jquery.*.js set ft=javascript syntax=jquery

  " handlebars
  au BufNewFile,BufRead *.handlebars.* set filetype=handlebars

  " Jimfile
  au BufNewFile,BufRead Jimfile set filetype=javascript

  " ruby. why.
  au BufNewFile,BufRead Vagrantfile,Podfile set filetype=ruby
endif

" Source a local configuration file if available.
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

set mouse=a

highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

autocmd FileType javascript set formatprg=prettier\ --stdin

let g:netrw_liststyle=3

let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exec = 'eslint_d'


" can haz spell
iab inpsection inspection
iab Inpsection Inspection

let g:airline_theme='zenburn'
colorscheme seoul256
