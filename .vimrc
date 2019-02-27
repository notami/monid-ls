" GENERAL MUST HAVES
"
set nocompatible			" Don't try to be vi compatible
filetype off				" Helps force plugins to load correctly when it is turned back on below
set modelines=5				" helps security
"

" VUNDLE "{{{
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/path/to/plugin'
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-commentary'
" Plugin 'suan/vim-instant-markdown'
Plugin 'vimwiki/vimwiki'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'ftan84/vim-khaled-ipsum'
Plugin 'mattn/emmet-vim' , {'on_ft': 'html'}
Plugin 'chriskempson/base16-vim'
Plugin 'powerline/powerline' , {'rtp': 'powerline/bindings/vim/'}
Plugin 'lifepillar/vim-cheat40'
Plugin 'shime/vim-livedown'
Plugin 'dhruvasagar/vim-table-mode'
Plugin 'junegunn/goyo.vim'
Plugin 'dylanaraps/wal.vim'
Plugin 'deviantfero/wpgtk.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'mboughaba/i3config.vim'
Plugin 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }}
" Plugin 'MikeCoder/markdown-preview.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"}}}

"set shell=zsh\ -i

" LEADER

let mapleader = (",")

" COLORS

set t_Co=256
set background=dark
colorscheme wal			" Set the colorscheme
syntax enable				" Turn on syntax highlighting
"

" Splits open at the bottom and right, which is non-retarded, unlike vim defaults.
set splitbelow
set splitright

" Easier split nav
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Replace all is aliased to S.
nnoremap S :%s//g<Left><Left>

" Interpret .md files, etc. as .markdown
let g:vimwiki_ext2syntax = {'.Rmd': 'markdown', '.rmd': 'markdown','.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}

augroup filetypes
  " Make calcurse notes markdown compatible:
  autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown

  " groff files automatically detected
  autocmd BufRead,BufNewFile *.ms,*.me,*.mom set filetype=groff

  " .tex files automatically detected
  autocmd BufRead,BufNewFile *.tex set filetype=tex

  " Readmes autowrap text:
  autocmd BufRead,BufNewFile *.md set tw=79
augroup END

" Get line, word and character counts with F3:
map <F3> :!wc %<CR>

" Spell-check set to F6:
map <F6> :setlocal spell! spelllang=en_us<CR>

" Use urlview to choose and open a url:
:noremap <leader>u :w<Home>silent <End> !urlscan<CR>
:noremap ,, :w<Home>silent <End> !urlscan<CR>

" Goyo plugin makes text more readable when writing prose:
map <F10> :Goyo<CR>
map <leader>f :Goyo \| set linebreak<CR>
inoremap <F10> <esc>:Goyo<CR>a

" Enable Goyo by default for mutt writting
" Goyo's width will be the line limit in mutt.
augroup goyo
  autocmd BufRead,BufNewFile /tmp/neomutt* let g:goyo_width=80
  autocmd BufRead,BufNewFile /tmp/neomutt* :Goyo
augroup END

augroup whitesp
  " Automatically deletes all tralling whitespace on save.
  autocmd BufWritePre * %s/\s\+$//e

  " When shortcut files are updated, renew bash and ranger configs with new material:
  autocmd BufWritePost ~/.key_directories,~/.key_files !bash ~/.scripts/tools/shortcuts

  " Runs a script that cleans out tex build files whenever I close out of a .tex file.
  autocmd VimLeave *.tex !texclear %

  " Disables automatic commenting on newline:
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

" TABS

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
"

" GENERAL GOODNESS

set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2
set relativenumber
set number
set undofile
set clipboard=unnamedplus
set clipboard^=unnamed      " copy paste bliss
set pastetoggle=<F2>

" LINE NUMBER TOGGLE
:set number relativenumber
"
" SAVE AS ROOT
" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" XCLIP
vmap <leader>xy :!xclip -f -sel clip<CR>
map <leader>xp mz:-1r !xclip -o -sel clip<CR>`z

" Automatically source .vimrc
augroup autosourcing
  autocmd!
  autocmd BufWritePost .vimrc source %
augroup END

" Use urlview to choose and open a url:
:noremap <leader>u :w<Home>silent <End> !urlview<CR>

" Get out of insert mode free
inoremap jk <Esc>

" Remaps shortcuts on save
augroup shcuts
  autocmd BufWritePost ~/.scripts/folders,~/.scripts/configs !bash ~/.scripts/shortcuts.sh
augroup END

"" PLUGIN OPTIONS
" Powerline for vim
let g:Powerline_symbols = 'fancy'

" vimwiki with markdown support"{{{
let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
" helppage -> :h vimwiki-syntax
" refresh preview
" let g:instant_markdown_autostart = 0 " disable autostart
map <leader>md :MarkdownPreview<CR>
map <leader>ms :MarkdownPreviewStop<CR>

" INSTANT MARKDOWN"{{{

" set to 1, the nvim will open the preview window once enter the markdown buffer
" default: 0
let g:mkdp_auto_start = 0

" set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 1

" set to 1, the vim will just refresh markdown when save the buffer or
" leave from insert mode, default 0 is auto refresh markdown as you edit or
" move the cursor
" default: 0
let g:mkdp_refresh_slow = 0

" set to 1, the MarkdownPreview command can be use for all files,
" by default it just can be use in markdown file
" default: 0
let g:mkdp_command_for_global = 0

" set to 1, preview server available to others in your network
" by default, the server only listens on localhost (127.0.0.1)
" default: 0
let g:mkdp_open_to_the_world = 0

" specify browser to open preview page
" default: ''
let g:mkdp_browser = ''

" set to 1, echo preview page url in command line when open preview page
" default is 0
let g:mkdp_echo_preview_url = 0

" a custom vim function name to open preview page
" this function will receive url as param
" default is empty
let g:mkdp_browserfunc = ''

" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
let g:mkdp_preview_options = {
      \ 'mkit': {},
      \ 'katex': {},
      \ 'uml': {},
      \ 'maid': {}
      \ }

" use a custom markdown style must be absolute path
let g:mkdp_markdown_css = ''

" use a custom highlight style must absolute path
let g:mkdp_highlight_css = ''

" use a custom port to start server or random for empty
let g:mkdp_port = ''
" }}}
" "}}}

" SEARCH SANITY
"{{{
set path+=**            " Provides tab-completion for all file-related tasks
set magic               "
" nnoremap / /\v			" regex fix
" vnoremap / /\v			" regex fix
set ignorecase			" intelligent case-sensitive search
set smartcase			" intelligent case-sensitive search
set gdefault			" applies substitutions globally on lines
set incsearch			" highlight search results
set showmatch			" highlight search results
set hlsearch			" highlight search results
nnoremap <leader><space> :noh<cr>	" gets rid of the distracting highlighting with ,<space>
nnoremap <tab> %		" tab key match bracket pairs
vnoremap <tab> %		" tab key match bracket pairs
"}}}
"
"WILD STUFFAGE"{{{
" Enable autocompletion:
set wildmenu wildmode=longest,list,full"{{{"}}}
" Ignore these filenames during enhanced command line completion.
set wildignore+=*.aux,*.out,*.toc " LaTeX intermediate files
set wildignore+=*.jpg,*.bmp,*.gif " binary images
set wildignore+=*.luac " Lua byte code
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest " compiled object files
set wildignore+=*.pyc " Python byte code
set wildignore+=*.spl " compiled spelling word lists
set wildignore+=*.sw? " Vim swap files
"

" CTRLP ignore
let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]\.(git|hg|svn)$',
      \ 'file': '\v\.(zip|so|swp)$',
      \ }
"}}}

"LINE WRAPPING

set wrap
set textwidth=79
set formatoptions=qrn1
set colorcolumn=85
"

"GENERAL GOODNESS
"
"=== folding ===
set foldmethod=marker   " fold based on {{{,}}}
set foldnestmax=10      " max 10 depth
set foldenable          " don't fold files by default on open
nnoremap <space> za
set foldlevelstart=0    " start with fold level of 1

" BOXES COMMENTING

vmap ,mc !boxes -d c-cmt<CR>
nmap ,mc !!boxes -d c-cmt<CR>
vmap ,xc !boxes -d c-cmt -r<CR>
nmap ,xc !!boxes -d c-cmt -r<CR>
vmap ,bc !boxes -d shell
nmap ,bc !!boxes -d shell
"
augroup boxes
  autocmd BufEnter * nmap ,mc !!boxes -d pound-cmt<CR>
  autocmd BufEnter * vmap ,mc !boxes -d pound-cmt<CR>
  autocmd BufEnter * nmap ,xc !!boxes -d pound-cmt -r<CR>
  autocmd BufEnter * vmap ,xc !boxes -d pound-cmt -r<CR>
  autocmd BufEnter *.html nmap ,mc !!boxes -d html-cmt<CR>
  autocmd BufEnter *.html vmap ,mc !boxes -d html-cmt<CR>
  autocmd BufEnter *.html nmap ,xc !!boxes -d html-cmt -r<CR>
  autocmd BufEnter *.html vmap ,xc !boxes -d html-cmt -r<CR>
  autocmd BufEnter *.[chly],*.[pc]c nmap ,mc !!boxes -d c-cmt<CR>
  autocmd BufEnter *.[chly],*.[pc]c vmap ,mc !boxes -d c-cmt<CR>
  autocmd BufEnter *.[chly],*.[pc]c nmap ,xc !!boxes -d c-cmt -r<CR>
  autocmd BufEnter *.[chly],*.[pc]c vmap ,xc !boxes -d c-cmt -r<CR>
  autocmd BufEnter *.C,*.cpp,*.java nmap ,mc !!boxes -d java-cmt<CR>
  autocmd BufEnter *.C,*.cpp,*.java vmap ,mc !boxes -d java-cmt<CR>
  autocmd BufEnter *.C,*.cpp,*.java nmap ,xc !!boxes -d java-cmt -r<CR>
  autocmd BufEnter *.C,*.cpp,*.java vmap ,xc !boxes -d java-cmt -r<CR>
  autocmd BufEnter .vimrc*,.exrc nmap ,mc !!boxes -d vim-cmt<CR>
  autocmd BufEnter .vimrc*,.exrc vmap ,mc !boxes -d vim-cmt<CR>
  autocmd BufEnter .vimrc*,.exrc nmap ,xc !!boxes -d vim-cmt -r<CR>
  autocmd BufEnter .vimrc*,.exrc vmap ,xc !boxes -d vim-cmt -r<CR>
augroup END

"=== BUFFERS ===
"{{{
" This allows buffers to be hidden if you've modified a buffer.
" This is almost a must if you wish to use buffers in this way.
set hidden

" To open a new empty buffer
" This replaces :tabnew which I used to bind to this mapping
nmap <leader>T :enew<cr>

" Move to the next buffer
nmap <leader>l :bnext<CR>

" Move to the previous buffer
nmap <leader>h :bprevious<CR>

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bq :bp <BAR> bd #<CR>

" Show all open buffers and their status
nmap <leader>bl :ls<CR>
"}}}

" Line Shortcuts
nnoremap G Gzz
nnoremap { {zz
nnoremap } }zz
"

" COMMAND SHORTCUTS
nnoremap ; :

" Save Read-only Files
cmap w!! w !sudo tee % >/dev/null

"quick pairs
imap <leader>' ''<ESC>i
imap <leader>" ""<ESC>i
imap <leader>( ()<ESC>i
imap <leader>[ []<ESC>i
imap <leader>{ {}<ESC>i
imap <leader>< < ><ESC>i
"

" Bubble single lines
nmap <C-Up> [e
nmap <C-Down> ]e

" Bubble multiple lines
vmap <C-Up> [egv
vmap <C-Down> ]egv

nmap <leader>t :NERDTreeToggle<CR>
nmap <leader>tm :TableModeToggle<CR>
let g:table_mode_corner='|'

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" TWIDDLE CASE

function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

"  RANGER AS BROWSER
" If you add this code to the .vimrc, ranger can be started using the command
" ":RangerChooser" or the keybinding "<leader>r".  Once you select one or more
" files, press enter and ranger will quit again and vim will open the selected
" files.

function! RangeChooser()
  let temp = tempname()
  " The option "--choosefiles" was added in ranger 1.5.1. Use the next line
  " with ranger 1.4.2 through 1.5.0 instead.
  "exec 'silent !ranger --choosefile=' . shellescape(temp)
  if has("gui_running")
    exec 'silent !xterm -e ranger --choosefiles=' . shellescape(temp)
  else
    exec 'silent !ranger --choosefiles=' . shellescape(temp)
  endif
  if !filereadable(temp)
    redraw!
    " Nothing to read.
    return
  endif
  let names = readfile(temp)
  if empty(names)
    redraw!
    " Nothing to open.
    return
  endif
  " Edit the first item.
  exec 'edit ' . fnameescape(names[0])
  " Add any remaning items to the arg list/buffer list.
  for name in names[1:]
    exec 'argadd ' . fnameescape(name)
  endfor
  redraw!
endfunction
command! -bar RangerChooser call RangeChooser()
nnoremap <leader>r :<C-U>RangerChooser<CR>endfunction
