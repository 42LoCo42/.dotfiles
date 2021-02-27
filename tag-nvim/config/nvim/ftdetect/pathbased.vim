augroup filetypedetect
    autocmd BufNew,BufNewFile,BufRead */i3/*     :setfiletype i3
    autocmd BufNew,BufNewFile,BufRead */sxhkd/*  :setfiletype sxhkd
    autocmd BufNew,BufNewFile,BufRead */sxrc.d/* :setfiletype sh
augroup END
