" Telescope """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if (has("nvim"))

    " Telescope """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      nnoremap <C-f> <cmd>Telescope find_files<cr>
      nnoremap <C-g> <cmd>Telescope live_grep<cr>
      nnoremap <C-b> <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
endif
