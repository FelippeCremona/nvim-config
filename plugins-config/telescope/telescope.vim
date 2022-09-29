" Telescope """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if (has("nvim"))

    " Telescope """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      nnoremap <leader>f <cmd>Telescope find_files<cr>
      nnoremap <leader>g <cmd>Telescope live_grep<cr>
      nnoremap <leader>b <cmd>Telescope buffers<cr>
      nnoremap <leader>help <cmd>Telescope help_tags<cr>
endif
