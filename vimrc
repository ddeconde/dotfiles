"
" .vimrc
" Last changed: Wed, 14 Oct 2015 11:02:53 -0700
"

if &compatible
    set nocompatible  " this is actually assumed when this .vimrc file exists
endif

"
" PLUGINS
"

" Load Plugins first to ensure that they are available to settings
" Plugins are managed with 'vim-plug'

" First, if the vim-plug plugin itself is not found, then automatically
" install it so that it can manage other plugins.

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Use vim-plug to install and manage all other plugins
call plug#begin('~/.vim/plugged')  " begin vim-plug calls

" GitHub-served plugins managed by vim-plug are specified in the format:
" Plug 'github_account/repository_name'

" Completion & Search Plugins
Plug 'kien/ctrlp.vim'  " full path fuzzy file, buffer, MRU, tag finder
Plug 'ervandew/supertab'  " use '<Tab>' for smart omnicompletions
Plug 'tpope/vim-vinegar'  " enhanced netrw file browser

" Editing Enhancement Plugins
Plug 'mbbill/undotree'  " visual navigation of VIM undotree
Plug 'tpope/vim-surround'  " easy handling of surrounding brackets etc.
Plug 'Raimondi/delimitMate'  " automatic closing of parentheses etc.
Plug 'junegunn/vim-easy-align'  " easy alignment of text blocks
Plug 'tpope/vim-commentary'  " easy toggling of comment markers
Plug 'tpope/vim-repeat'  " make vim-surround and vim-commentary repeatable

" Source Code Management Tool Plugins
Plug 'tpope/vim-fugitive'  " git integration for VIM
Plug 'scrooloose/syntastic'  " syntax checking for many languages

" Appearance Plugins
Plug 'altercation/vim-colors-solarized'  " selective-contrast colorscheme
Plug 'Yggdroot/indentLine'  " display indentation guides
Plug 'chriskempson/base16-vim'
" Plug 'matthiaskern/vim-monochrome'
Plug 'kcsongor/vim-monochrome'
" Plug 'fxn/vim-monochrome'
Plug 'bvf/preto'
Plug 'andreypopp/vim-colors-plain'
Plug 'treycucco/vim-monotonic'
Plug 'owickstrom/vim-colors-paramount'
Plug 'cloud-oak/vim-colors-alchemy'
Plug 'xdefrag/vim-beelzebub'
Plug 'logico-dev/typewriter'
Plug 'clinstid/eink.vim'
Plug 'noahfrederick/vim-noctu'
Plug 'romainl/flattened'
" Plug 'flazz/vim-colorschemes'

" Filetype Specific Plugins
Plug 'LaTeX-Box-Team/LaTeX-Box'  " LaTeX support

" All plugins must be added before the following lines
call plug#end()  " end vim-plug calls


"
" PLUGIN CONFIGURATION
"

" netrw (built-in)
let g:netrw_liststyle = 3  " default to tree-style file listing
let g:netrw_winsize   = 30  " use 30% of columns for list
let g:netrw_preview   = 1  " default to vertical splitting for preview
 
" ctrlp
if executable("ag")
    " Use Ag in CtrlP for listing files
    let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'

    " Ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0
endif

" supertab
let g:SuperTabDefaultCompletionType = "context"

" undotree
nnoremap <Leader>u :UndotreeToggle<CR>

" vim-easy-align
" Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
vmap <Enter> <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. <Leader>aip)
nmap <Leader>a <Plug>(EasyAlign)

" vim-colors-solarized
" Toggle solarized colorscheme background between dark and light
silent! call togglebg#map("<F5>")

" syntastic
let g:syntastic_mode_map = { "mode":"passive",
            \"active_filetypes": ["haskell", "tex", "python",
            \ "sh", "ruby"],
            \"passive_filetypes": [ ]}
let g:syntastic_haskell_checkers = ['hdevtools', 'hlint']
let g:syntastic_tex_checkers = ['chktex', 'lacheck']
let g:syntastic_python_checkers = ['flake8', 'python']
let g:syntastic_sh_checkers = ['shellcheck', 'sh']
let g:syntastic_ruby_checkers = ['mri', 'ruby']
let g:syntastic_markdown_checkers = ['mdl']
let g:syntastic_enable_signs=1
let g:syntastic_stl_format=" Syntax: line:%F (%t) "
" Pull up syntastic errors easily
nnoremap <Leader>e :Errors<CR>
" Reset syntastic easily in both normal and insert mode
imap <F3> <C-O><F3>
nnoremap <F3> :SyntasticReset<CR>

" indentLine
imap <F6> <C-O><F6>
nnoremap <F6> :IndentLinesToggle<CR>

imap <F7> <C-O><F7>
nnoremap <F7> :call ToggleIndentGuides()<CR>


"
" SETTINGS
"

" File Handling
set nomodeline  " don't use modelines, they are a security risk
set autoread  " reread files that have been changed while open
set autowrite  " write modified files when moving to other buffers/windows
set encoding=utf-8  " the encoding displayed
scriptencoding utf-8 " always use utf-8 encoding within the vimrc

" Display
syntax enable  " enable syntax highlighting
set showmode  " show current mode at bottom of screen
set showcmd  " show (partial) commands below statusline
set showmatch  " show matching paretheses, brackets, and braces
set number  " display line number of cursor location
set relativenumber  " display relative line numbers
set numberwidth=4  " always make room for 4-digit line numbers
set display+=lastline  " display as much as possible of the last line
set lazyredraw  " don't redraw unnecessarily during macros etc.
set ttyfast  " indicate that the terminal connection is fast
set wrap  " wrap long lines
set linebreak  " don't break words when wrapping; will be disabled by list
set listchars=tab:»·,trail:·  " show whitespace with UTF-8 Characters
" set listchars=tab:>-,trail:.  " show whitespace with ASCII characters
set visualbell  " flash screen instead of audio bell for alert
" set visualbell t_vb=  " turn off visualbell effect
" set title  " update terminal window title
set shortmess+=A  " don't show 'ATTENTION' warning for existing swapfiles
set background=dark
" try
"     colorscheme solarized
" catch
"     colorscheme pablo
" endtry
silent! colorscheme flattened
" When using solarized without custom terminal colors use the following
" let g:solarized_termcolors=256

" Editing
set backspace=indent,eol,start  " backspace over line breaks, insertion start
set history=1000  " by default command history is only the last 20
set undolevels=1000  " enable many levels of undo
set undofile  " save undo tree to file for persistent undos
set clipboard+=unnamed  " make yanked text avilable in system clipboard
set scrolloff=3  " always show 3 lines above or below cursor when scrolling
set scrolljump=3  " scroll 3 lines when the cursor would leave the screen

" VIM Files
set directory=/var/tmp//,/tmp//  " set swap file directory
set backupdir=/var/tmp//,/tmp//  " set backup file directory
set undodir=/var/tmp//,/tmp//  " set undo file directory

" Indentation & Formatting
set autoindent  " retain indentation on next line for non-specific filetypes
set shiftwidth=4  " by default indent 4 spaces using '>>'
" set tabstop=4  " show tabs as 4 spaces (default is 8)
set softtabstop=4  " when editing tabs are 4 spaces wide
set expandtab  " all tabs are converted to spaces
set smarttab  " use 'shiftwidth' for tabs rather than 'tabstop'
set shiftround  " round all indentation to multiples of 'shiftwidth'
set nojoinspaces  " make 'J' and 'gq' only add one space after a period
set textwidth=79  " default format of no more than 79 characters in a line
" set formatoptions=tcq  " this is the default, add 'a' for auto-rewrap

" Buffers & Windows
set hidden  " don't close windowless buffers
set confirm  " get confirmation to discard unwritten buffers
" Open new windows below and to the right (default is opposite)
" set splitbelow
" set splitright

" Search & Substitution
set hlsearch  " highlight search results
set incsearch  " incremental search begins as you type
set ignorecase  " use case insensitive search
set smartcase  " except when capital letters are entered in the pattern
" set gdefault  " make substitutions global by default: this reverses convention
" Use Ag, The Silver Searcher, for grep
if executable("ag")
    " Use Ag as grep program
    set grepprg=ag\ --nogroup\ --nocolor\ --ignore-case\ --column\ --hidden

    " Set a more complete grepformat
    set grepformat=%f:%l:%c:%m,%f:%l:%m

    " Add an 'Ag' command
    com! -nargs=+ -complete=file_in_path -bar Ag silent grep! <args>|cw|redr!
endif

" Completion
set completeopt+=longest
set wildmenu  " command-line completion
set wildmode=list:longest,full  " shell-style completion behavior
" File types to ignore for command-line completion
set wildignore+=*.DS_Store  " OSX folder meta-data file
set wildignore+=.git,.hg,.svn  " version control system files
set wildignore+=*.o,*.obj,*.exe  " compiled object files
set wildignore+=*.jpg,*.gif,*.png,*.jpeg  "binary image files
set wildignore+=*.aux,*.out,*.toc,*.pdf  "LaTeX intermediate/output files
set wildignore+=*.pyc  " python object codes
set wildignore+=*.luac  " lua byte code
set wildignore+=*.class  " java/scala class files
set wildignore+=*/target/*  " sbt target directory

" Folding
set foldenable  " default to folding on, can be toggled with 'zi'
set foldlevelstart=99  " open files completely unfolded
set foldnestmax=8  " no more than 8 levels of folds
set foldmethod=indent  "default to indentation-based folding

" Add highlight groups for statusline
function! UserHighlights() abort
    highlight User1 term=reverse cterm=reverse ctermfg=4
    highlight User2 term=reverse cterm=reverse ctermfg=2
    highlight User3 term=reverse cterm=reverse ctermfg=5
    highlight User4 term=reverse cterm=reverse ctermfg=1
    highlight User5 term=reverse cterm=reverse ctermfg=13
    highlight User6 term=reverse cterm=reverse ctermfg=3
    highlight User7 term=reverse cterm=reverse ctermfg=0 ctermbg=14 gui=bold,reverse
    highlight User8 ctermfg=9 ctermbg=0
endfunction

augroup UserColors
    autocmd!
    autocmd Colorscheme * call UserHighlights()
augroup END

try
    colorscheme solarized
catch
    colorscheme pablo
endtry

" Map mode() outputs to mode types and labels for statusline
let g:modetype={
      \ 'n'      : ['N', '  NORMAL '],
      \ 'no'     : ['N', '  N·OPERATOR PENDING '],
      \ 'v'      : ['V', '  VISUAL '],
      \ 'V'      : ['V', '  V·LINE '],
      \ "\<C-v>" : ['V', '  V·BLOCK '],
      \ 's'      : ['I', '  SELECT '],
      \ 'S'      : ['I', '  S·LINE '],
      \ "\<C-s>" : ['I', '  S·BLOCK '],
      \ 'i'      : ['I', '  INSERT '],
      \ 'R'      : ['R', '  REPLACE '],
      \ 'Rv'     : ['R', '  V·REPLACE '],
      \ 'c'      : ['E', '  COMMAND '],
      \ 'cv'     : ['E', '  VIM EX '],
      \ 'ce'     : ['E', '  EX '],
      \ 'r'      : ['S', '  PROMPT '],
      \ 'rm'     : ['S', '  MORE '],
      \ 'r?'     : ['S', '  CONFIRM '],
      \ '!'      : ['S', '  SHELL '],
      \ 't'      : ['S', '  TERMINAL ']
      \}

" Statusline
set laststatus=2  " always display statusline
set ruler  " display cursor position even with empty statusline
set statusline=
" modes are mutually exclusive so only one of the following applies
set statusline+=%1*%{(modetype[mode()][0]==#'N')?modetype[mode()][1]:''}
set statusline+=%2*%{(modetype[mode()][0]==#'I')?modetype[mode()][1]:''}
set statusline+=%3*%{(modetype[mode()][0]==#'V')?modetype[mode()][1]:''}
set statusline+=%4*%{(modetype[mode()][0]==#'R')?modetype[mode()][1]:''}
set statusline+=%5*%{(modetype[mode()][0]==#'E')?modetype[mode()][1]:''}
set statusline+=%6*%{(modetype[mode()][0]==#'S')?modetype[mode()][1]:''}
" set statusline+=%*
" set statusline+=%9*%{&paste?'\ \ PASTE\ ':''}%*  " paste mode
" set statusline+=%8*%{&spell?'\ \ SPELL\ ':''}%*  " paste mode
" set statusline+=%8*%{&list?'\ \ LIST\ ':''}%*  " paste mode
" set statusline+=%#WildMenu#%(\ %n\ \|%)%<  " buffer number and truncation
" set statusline+=%#WildMenu#%(\ %n\ %)  " buffer number and truncation
" set statusline+=%#WildMenu#%(\ %f\ %)  " filename
set statusline+=%*%(\ %n\ \|%)%<  " buffer number and truncation
" set statusline+=%(\ %f\ %)  " filename
set statusline+=%*%(\ %t\ %)%<  " filename
" set statusline+=%(\ %t\ %)  " filename
set statusline+=%r  " read only flag: [RO]
" set statusline+=%m%*  " modified flag: [+][-]
set statusline+=%m  " modified flag: [+][-]
" set statusline+=%7*%(\ %)
set statusline+=%#FoldColumn#%(\ %)
set statusline+=%{&paste?'\[paste\]':''}  " paste mode
set statusline+=%{&list?'\[list\]':''}  " listed characters displayed
set statusline+=%=  " right-align the rest of the statusline
" set statusline+=%8*%{SyntasticStatuslineFlag()}%7*  " syntastic
set statusline+=%#DiffDelete#%{SyntasticStatuslineFlag()}%#FoldColumn#  " syntastic
set statusline+=[%{&fileformat}]  " file format
set statusline+=[%{strlen(&fenc)?&fenc:&enc}]  " file encoding
" set statusline+=[%{strlen(&filetype)?&filetype:'no\ ft'}]  " file type
set statusline+=%y  " file type
set statusline+=%w  " preview window flag: [Preview]
" set statusline+=%(\ %)%#ModeMsg#%{&paste?'\ PASTE\ ':''}%*  " paste mode
" set statusline+=%#Search#%{SyntasticStatuslineFlag()}%*  " syntastic
set statusline+=%(\ %)
set statusline+=%*%(\ %3p%%\ \|%)  " scroll percentage
" set statusline+=%*%(\ %3p%%\ %)  " scroll percentage
" set statusline+=%#WildMenu#%(\ %3p%%\ \|%)  " scroll percentage
" set statusline+=%#WildMenu#%(\ %3l:%-2v\ %)%*  " line:virtualcolumn
set statusline+=%(\ %3l:%-2v\ %)%*  " line:virtualcolumn


"
" KEY BINDINGS
"

" Movement & Editing
" Recall that 'Ctrl-[' is already equivalent to '<Esc>'
" Make Ctrl-Space act as Escape while in Insert-Mode
inoremap <C-@> <Esc>
" Move around wrapped long lines more naturally
nnoremap j gj
nnoremap k gk
nnoremap 0 g0
nnoremap ^ g^
nnoremap $ g$
vnoremap j gj
vnoremap k gk
vnoremap ^ g^
vnoremap $ g$
" Make Y behave analagously to C and D
nnoremap Y y$
" Retain visual mode selection while changing indenting
vnoremap > >gv
vnoremap < <gv
" Reselect just pasted text in visual mode
nnoremap <Leader>v V`]
" Allow sudo writing of protected files using 'w!!'
cmap w!! w !sudo tee % >/dev/null
" Protect against accidentally winding up in Ex mode
nnoremap Q <Nop>

" Toggles
" Toggle and echo paste mode easily (even while in insert mode)
set pastetoggle=<F2>
nnoremap <Leader>p :set paste!<CR>:set paste?<CR>
" Toggle and echo display of some whitespace characters
nnoremap <Leader>l :set list!<CR>:set list?<CR>
" Toggle and echo dislpay of relative line numbers
nnoremap <Leader>r :set relativenumber!<CR>:set relativenumber?<CR>
" Toggle English spell checking in local buffer only
nnoremap <Leader>s :setlocal spell! spelllang=en_us<CR>:setlocal spell?<CR>
" Toggle highlighting of textwidth column
nnoremap <Leader>cc :set colorcolumn=+1<CR>
nnoremap <Leader>CC :set colorcolumn=<CR>
" Toggle highlighting of cursor position
nnoremap <Leader>cp :set cursorline!<Bar>:set cursorcolumn!<CR>

" Searching
" Map search '/' key to always be very-magic, i.e. full regex support
nnoremap / /\v
vnoremap / /\v
" Map F4 to clear search highlights
imap <F4> <C-O><F4>
nnoremap <F4> :nohlsearch<CR><C-L>
" Bind Ctrl-H to grep word under cursor
nnoremap <C-H> :silent! grep! "\b<C-r><C-w>\b"<CR>:cw<CR>:redr!<CR>

" Formatting
" Strip all trailing whitespace without losing search history
nnoremap <Silent> <Leader>$ :let _s=@/<Bar>:%s/\s\+$//e<Bar>
    \ :let @/=_s<Bar>:nohl<CR>
" Reindent the entire file while fixing cursor (indentation only)
nnoremap <Silent> <Leader>= :let l=line(".")<Bar>:let c=virtcol(".")<Bar>
    \ :normal gg=G<Bar>:call cursor(l, c)<Bar>:unlet l<Bar>:unlet c<CR> 
" Reformat the entire file while fixing cursor (indentation and linebreaks)
nnoremap <Silent> <Leader>q :let l=line(".")<Bar>:let c=virtcol(".")<Bar>
    \ :normal gggqG<Bar>:call cursor(l, c)<Bar>:unlet l<Bar>:unlet c<CR> 
" As for gq above, but gw fixes cursor by default and ignores 'formatprg'
nnoremap <Silent> <Leader>w :let l=line(".")<Bar>:let c=virtcol(".")<Bar>
    \ :normal gggwG<Bar>:call cursor(l, c)<Bar>:unlet l<Bar>:unlet c<CR> 
" Reindent the current paragraph
nnoremap <Leader>q gqip

" Windows & Buffers
" See a list of buffers and hit a number to select one
nnoremap <Leader>b :buffers<CR>:buffer<Space>
" Move to next or previous buffer easily
noremap <C-N> :bn
noremap <C-P> :bp
" Move to next or previous window easily
noremap <C-J> <C-W>w
noremap <C-K> <C-W>W
" Split current window and move to new split (w: vertical, W: horizontal)
nnoremap <Leader>w <C-w>v<C-w>l
nnoremap <Leader>W <C-w>s<C-w>j


" Make alterations to this file more easily
nnoremap <Leader>ev :vsplit $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>

"
" CURSOR SHAPE
"


" Use a blinking upright bar cursor in Insert mode, a blinking block in normal
if &term == 'xterm-256color' || &term == 'screen-256color'
    let &t_SI = "\<Esc>[5 q"
    let &t_EI = "\<Esc>[1 q"
endif

if exists('$STY')
    let &t_EI = "\<Esc>P\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    let &t_SI = "\<Esc>P\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
endif
if exists('$TMUX')
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
endif


"
" FILETYPE SPECIFIC SETTINGS
"

" Be certain to check the ftplugin for a given filetype before assuming
" that local settings must be included here.

augroup Filetypes " define an auto-command group for filetypes
" idiomatic removal of all auto-commands for this group
autocmd!

" Force *.md to be considered Markdown as I never use Modula-2
autocmd BufNewFile,BufRead *.md set filetype=markdown

" Make certain that .txt files are identified as filetype Text
autocmd BufNewFile,BufRead *.txt set filetype=text

" Turn on spell check for certain filetypes automatically
autocmd FileType markdown setlocal spell spelllang=en_us
autocmd FileType gitcommit setlocal spell spelllang=en_us
autocmd FileType text setlocal spell spelllang=en_us

" Set textwidth automatically for certain filetypes
" Note that for many filetypes ftplugin files already handle this
autocmd FileType markdown setlocal textwidth=72
autocmd FileType text setlocal textwidth=72

" Set formatoptions automatically for certain filetypes
" autocmd Filetype text setlocal formatoptions=

" Idomatic seletion of default auto-command group
augroup END


"
" ABBREVIATIONS
"

" Abbreviation for date and time stamp in RFC822 format
iabbrev <expr> dts strftime("%a, %d %b %Y %H:%M:%S %z")

" Abbreviation for #! line
iabbrev #!! #!/usr/bin/env

"
" LOCAL
"

" If a local vimrc is available then source that too
let $LOCALFILE=expand("~/.vimrc_local")
if filereadable($LOCALFILE)
    source $LOCALFILE
endif

" Alternative indent highlighting function
function! ToggleIndentGuides()
    if exists('b:indent_guides')
        call matchdelete(b:indent_guides)
        unlet b:indent_guides
    else
        " let pos = range(1, &l:textwidth, &l:shiftwidth)
        let pos = range(&l:shiftwidth, &l:textwidth, &l:shiftwidth)
        call map(pos, '"\\%" . v:val . "v"')
        let pat = '\%(\_^\s*\)\@<=\%(' . join(pos, '\|') . '\)\s'
        let b:indent_guides = matchadd('CursorLine', pat)
    endif
endfunction
