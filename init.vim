"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Maintainer:
"    Christopher Phillips - @spiffcs
"
"
" Sections:
"    -> Plugins
"    -> General
"    -> VIM UX
"    -> Visual mode
"    -> Text, tab and indent related
"    -> Tabs, Windows and Buffers
"    -> Ack searching and cope displaying
"    -> Colors and Fonts
"    -> Coc.nvim
"    -> Golang
"    -> Python
"    -> Nerdtree
"    -> Functions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neovim/nvim-lspconfig'
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'ntpeters/vim-better-whitespace'
Plug 'sebdah/vim-delve'
Plug 'honza/vim-snippets'
Plug 'mileszs/ack.vim'
Plug 'rust-lang/rust.vim'

Plug 'fatih/vim-go', { 'do': 'GoInstallBinaries' }
call plug#end()

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

set updatetime=300
set shortmess+=c
set signcolumn=yes

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

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

" Remap <C-f> and <C-b> for scroll float windows/popups.
" Note coc#float#scroll works on neovim >= 0.4.3 or vim >= 8.2.0750
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

" NeoVim-only mapping for visual mode scroll
" Useful on signatureHelp after jump placeholder of snippet expansion
if has('nvim')
  vnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#nvim_scroll(1, 1) : "\<C-f>"
  vnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#nvim_scroll(0, 1) : "\<C-b>"
endif

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Golang
""""""""""""""""""""""""""""""""""""""""""""""""""
" Have go run goimports on save
let g:go_fmt_command = "goimports"

" Have meta linter run on save
let g:go_metalinter_autosave = 1

" Have write happen on build for golang
set autowrite

" Easy go run, go build, and go test
autocmd FileType go nmap <leader>r <Plug>(go-run)
autocmd FileType go nmap <leader>t <Plug>(go-test)
autocmd FileType go nmap <leader>c <Plug>(go-coverage-toggle)

" Add camel case for json completion
let g:go_addtags_transform = "camelcase"

" Syntax highlighting
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Tabs, Windows and Buffers
""""""""""""""""""""""""""""""""""""""""""""""""""
" Map <Space> to / (search) and Ctrl<Space> to ? (backwards search)
map <space> /
map <c-space> ?

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
map <leader> ba :bufdo bd<cr>

" Next and Previous buffer
map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Smar tab moves
map <C-t><up> :tabr<cr>

map <C-t><down> :tabl<cr>

map <C-t><left> :tabp<cr>

map <C-t><right> :tabn<cr>
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
" => Ack searching and cope displaying
" 	 Requires ack.vim -
""""""""""""""""""""""""""""""""""""""""""""""""""
" Use the_silver_searcher if possible
if executable('ag')
    let g:ackprg = 'ag --vimgrep --smart-case'
endif

" When you press gv you Ack after the selected text
vnoremap <silent> gv :call VisualSelection('gv', '')<CR>

" Open Ack and put the cursor in the right position
map <leader>g :Ack


" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

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

" Set utf8 as the standard encoding
set encoding=utf8

""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerdtree
""""""""""""""""""""""""""""""""""""""""""""""""""
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

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
" => Functions
""""""""""""""""""""""""""""""""""""""""""""""""""
function! CmdLine(str)
    call feedkeys(":", a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
