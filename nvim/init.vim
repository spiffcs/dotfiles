""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Maintainer:
"    Christopher Phillips - @spiffcs
"
" Sections:
"    -> Plugins
"    -> General
"    -> VIM UX
"    -> Colors and Fonts
"    -> Tabs, Windows and Buffers
"    -> Text, tab and indent related
"    -> Nerdtree
"    -> vim-ctrlspace
"    -> Coc.nvim
"    -> Golang
"    -> Rust
"    -> Ack searching and cope displaying
"
""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""
" Auto install vim-plug
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a director for plugins
" - For Neovim: ~/.vim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" base
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"ui
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ntpeters/vim-better-whitespace'

" code
Plug 'fatih/vim-go', { 'do': 'GoInstallBinaries' }
Plug 'neovim/nvim-lspconfig'
Plug 'rust-lang/rust.vim'
Plug 'github/copilot.vim'

" Search
Plug 'mileszs/ack.vim'
Plug 'vim-ctrlspace/vim-ctrlspace'

call plug#end()
""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" Set line numbers in file
set number
set numberwidth=1

" turn hybrid line numbers on
set number relativenumber
set nu rnu

" With a mapleader it is possible to do extra key combinations
" EX: <leader>w saves the current file
let mapleader = ","

" Fast saving
nmap <leader>w :w!<cr>

" nocompatible for vim-ctrlspace
set nocompatible

" set mouse support for normal and visual mode
set mouse=nv

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM UX
""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Turn on the Wild menu
set wildmenu

" Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" Ignore case when searching, hilight results
set ignorecase
set smartcase
set hlsearch
set incsearch

" Don't redraw while executing macros (performance)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indivator is over them
set showmatch
set mat=2

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

set termguicolors
set background=dark
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

try
    colorscheme gruvbox
catch
endtry

" Airline Theme
let g:airline_theme='base16_gruvbox_dark_hard'

" Set utf8 as the standard encoding
set encoding=utf8

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => Tabs, Windows and Buffers
""""""""""""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search)
map <space> /

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close the current buffer
map <leader> bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
map <leader> ba :bufdo bd<cr> :bufdo bd

" Next and Previous buffer
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Smar tab moves
map <C-t>k :tabr<cr>
map <C-t>j :tabl<cr>
map <C-t>h :tabp<cr>
map <C-t>l :tabn<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
""""""""""""""""""""""""""""""""""""""""""""""""""
" Use tabs instead of spaces
set autoindent
set noexpandtab

" 1 tab == 4 spaces
set tabstop=4
set shiftwidth=4

" Linebreak on 500 char
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerdtree
""""""""""""""""""""""""""""""""""""""""""""""""""
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-ctrlspace
""""""""""""""""""""""""""""""""""""""""""""""""""
let g:CtrlSpaceDefaultMappingKey = "<C-space> "

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => Coc.nvim
""""""""""""""""""""""""""""""""""""""""""""""""""
" If hidden is not set, TextEdit might fail.
set hidden

" Turn backup off. We have git
set nobackup
set nowritebackup
set nowb
set noswapfile

set updatetime=100
set shortmess+=c
set signcolumn=yes

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Remap keys for applying codeAction to the current selection.
nmap <leader>a v<Plug>(coc-codeaction-selected)

" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use <Tab> and <S-Tab> to navigate the completion list:
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

" To make <cr> select the first completion item and confirm the completion when no item has been selected:
inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => Golang
""""""""""""""""""""""""""""""""""""""""""""""""""
" Have go run goimports on save
let g:gofmt_command = "goimports"

" Have write happen on build for golang
set autowrite

" jump to the first error automatically
let g:go_jump_to_error = 1

" Easy go run, go build, and go test
autocmd FileType go nmap <leader>r <Plug>(go-run)
autocmd FileType go nmap <leader>t <Plug>(go-test)
autocmd FileType go nmap <leader>c <Plug>(go-coverage-toggle)

" Add camel case for json completion
let g:go_addtags_transform = "camelcase"

" Syntax highlighting
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_variable_declarations = 0
let g:go_highlight_variable_assignments = 0
let g:go_highlight_build_constraints = 0

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => Rust
""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
require'lspconfig'.rust_analyzer.setup{
  cmd = { "rust-analyzer" };
  filetypes = { "rust" };
  settings = {
    ["rust-analyzer"] = {}
  }
}
EOF

""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ack searching and cope displaying
" 	 Requires ack.vim -
""""""""""""""""""""""""""""""""""""""""""""""""""
" Use the_silver_searcher if possible
if executable('ag')
    let g:ackprg = 'ag --vimgrep --smart-case'
endif

" Open Ack and put the cursor in the right position
map <leader>g :Ack

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with Ack, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p

map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>