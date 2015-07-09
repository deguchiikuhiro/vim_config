if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  " Cのタブ幅は4で
  au BufNewFile,BufRead *.c    setlocal tabstop=4 softtabstop=4 shiftwidth=4
  au BufNewFile,BufRead *.cpp  setlocal tabstop=4 softtabstop=4 shiftwidth=4
  au BufNewFile,BufRead *.h    setlocal tabstop=4 softtabstop=4 shiftwidth=4
  au BufNewFile,BufRead *.py   setlocal tabstop=4 softtabstop=4 shiftwidth=4
  au BufNewFile,BufRead *.rb   setlocal tabstop=2 softtabstop=2 shiftwidth=2
  au BufNewFile,BufRead *.json setlocal tabstop=2 softtabstop=2 shiftwidth=2
  au BufNewFile,BufRead *.txt  setlocal tabstop=2 softtabstop=2 shiftwidth=2
augroup END
