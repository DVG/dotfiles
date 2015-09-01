" NeoBundles are managed by Vundle. Once VIM is open run :NeoBundleInstall to
" install NeoBundles.

NeoBundleFetch 'Shougo/neobundle.vim'

" NeoBundles requiring no additional configuration or keymaps
NeoBundle 'oscarh/vimerl.git'
NeoBundle 'tpope/vim-git.git'
NeoBundle 'harleypig/vcscommand.vim.git'
NeoBundle 'tpope/vim-cucumber.git'
NeoBundle 'pangloss/vim-javascript.git'
NeoBundle 'tpope/vim-rake.git'
NeoBundle 'vim-ruby/vim-ruby.git'
NeoBundle 'tpope/vim-repeat.git'
NeoBundle 'vim-scripts/ruby-matchit.git'
NeoBundle 'wgibbs/vim-irblack.git'
NeoBundle 'tpope/vim-abolish.git'
NeoBundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
NeoBundle 'thoughtbot/vim-rspec'
NeoBundle 'godlygeek/tabular'
NeoBundle 'plasticboy/vim-markdown'

" Automatically wrap long commit messages
au FileType gitcommit set tw=72

" CtrlP - with FuzzyFinder compatible keymaps
NeoBundle 'kien/ctrlp.vim'
nnoremap <Leader>b :<C-U>CtrlPBuffer<CR>
nnoremap <Leader>t :<C-U>CtrlP<CR>
nnoremap <Leader>T :<C-U>CtrlPTag<CR>
let g:ctrlp_prompt_mappings = {
  \ 'PrtSelectMove("j")':   ['<down>'],
  \ 'PrtSelectMove("k")':   ['<up>'],
  \ 'AcceptSelection("h")': ['<c-j>'],
  \ 'AcceptSelection("v")': ['<c-k>', '<RightMouse>'],
  \ }
  " respect the .gitignore
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others']

  " Mustache
  NeoBundle 'juvenn/mustache.vim.git'
  " Copied from the NeoBundle; not sure why it isn't working normally
  au BufNewFile,BufRead *.mustache,*.handlebars,*.hbs set filetype=mustache

  " Slim
  NeoBundle 'slim-template/vim-slim.git'
  au BufNewFile,BufRead *.slim set filetype=slim

  " Emblem
  NeoBundle 'heartsentwined/vim-emblem.git'
  au BufNewFile,BufRead *.emblem set filetype=emblem
  au BufNewFile,BufRead *.em set filetype=emblem

  " Handlebars
  NeoBundle 'nono/vim-handlebars.git'
  au BufNewFile,BufRead *.hbs set filetype=handlebars

  " Coffee script
  NeoBundle 'kchmck/vim-coffee-script.git'
  au BufNewFile,BufRead *.coffee set filetype=coffee

  " Tagbar for navigation by tags using CTags
  NeoBundle 'majutsushi/tagbar.git'
  let g:tagbar_autofocus = 1
  map <Leader>rt :!ctags --extra=+f -R *<CR><CR>
  map <Leader>. :TagbarToggle<CR>

  " Markdown syntax highlighting
  NeoBundle 'tpope/vim-markdown.git'
  augroup mkd
  autocmd BufNewFile,BufRead *.mkd      set ai formatoptions=tcroqn2 comments=n:> filetype=markdown
  autocmd BufNewFile,BufRead *.md       set ai formatoptions=tcroqn2 comments=n:> filetype=markdown
  autocmd BufNewFile,BufRead *.markdown set ai formatoptions=tcroqn2 comments=n:> filetype=markdown
  augroup END

  " NERDTree for project drawer
  NeoBundle 'scrooloose/nerdtree.git'
  let NERDTreeHijackNetrw = 0

  nmap gt :NERDTreeToggle<CR>
  nmap g :NERDTree \| NERDTreeToggle \| NERDTreeFind<CR>


  " Tabular for aligning text
  NeoBundle 'godlygeek/tabular.git'
  function! CustomTabularPatterns()
  if exists('g:tabular_loaded')
  AddTabularPattern! symbols         / :/l0
  AddTabularPattern! hash            /^[^>]*\zs=>/
  AddTabularPattern! chunks          / \S\+/l0
  AddTabularPattern! assignment      / = /l0
  AddTabularPattern! comma           /^[^,]*,/l1
  AddTabularPattern! colon           /:\zs /l0
  AddTabularPattern! options_hashes  /:\w\+ =>/
  endif
  endfunction

  autocmd VimEnter * call CustomTabularPatterns()

  " shortcut to align text with Tabular
  map <Leader>a :Tabularize<space>

  " ZoomWin to fullscreen a particular buffer without losing others
  NeoBundle 'vim-scripts/ZoomWin.git'
  map <Leader>z :ZoomWin<CR>

  " Unimpaired for keymaps for quicky manipulating lines and files
  NeoBundle 'tpope/vim-unimpaired.git'
  " Bubble single lines
  nmap <C-Up> [e
  nmap <C-Down> ]e

  " Bubble multiple lines
  vmap <C-Up> [egv
  vmap <C-Down> ]egv


  " Syntastic for catching syntax errors on save
  NeoBundle 'scrooloose/syntastic.git'
  let g:syntastic_enable_signs=1
  let g:syntastic_quiet_messages = {'level': 'warning'}
  " syntastic is too slow for haml and sass
  let g:syntastic_mode_map = { 'mode': 'active',
  \ 'active_filetypes': [],
  \ 'passive_filetypes': ['haml','scss','sass'] }


  " gist-vim for quickly creating gists
  NeoBundle 'mattn/webapi-vim.git'
  NeoBundle 'mattn/gist-vim.git'
  if has("mac")
  let g:gist_clip_command = 'pbcopy'
  elseif has("unix")
  let g:gist_clip_command = 'xclip -selection clipboard'
  endif

  let g:gist_detect_filetype = 1
  let g:gist_open_browser_after_post = 1


  " gundo for awesome undo tree visualization
  NeoBundle 'sjl/gundo.vim.git'
  map <Leader>h :GundoToggle<CR>


  " rails.vim, nuff' said
  NeoBundle 'tpope/vim-rails.git'
  map <Leader>oc :Rcontroller<Space>
  map <Leader>ov :Rview<Space>
  map <Leader>om :Rmodel<Space>
  map <Leader>oh :Rhelper<Space>
  map <Leader>oj :Rjavascript<Space>
  map <Leader>os :Rstylesheet<Space>
  map <Leader>oi :Rintegration<Space>


  " surround for adding surround 'physics'
  NeoBundle 'tpope/vim-surround.git'
  " # to surround with ruby string interpolation
  let g:surround_35 = "#{\r}"
  " - to surround with no-output erb tag
  let g:surround_45 = "<% \r %>"
  " = to surround with output erb tag
  let g:surround_61 = "<%= \r %>"
