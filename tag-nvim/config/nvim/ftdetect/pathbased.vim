augroup filetypedetect
    autocmd BufNew,BufNewFile,BufRead */.config/i3/*              :setfiletype i3
    autocmd BufNew,BufNewFile,BufRead */.config/polybar/modules/* :setfiletype dosini
    autocmd BufNew,BufNewFile,BufRead */.config/sx/*              :setfiletype sh
    autocmd BufNew,BufNewFile,BufRead */.config/sxhkd/*           :setfiletype sxhkd
augroup END
