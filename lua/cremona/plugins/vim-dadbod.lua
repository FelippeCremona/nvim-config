return {
  { "tpope/vim-dadbod", lazy = true },

  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Precisa estar setado antes do plugin carregar. A conexão em si (g:db)
      -- vem do init.lua — o dadbod-ui já lista g:db sozinho, sem precisar
      -- duplicar em g:dbs.
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"

      -- O dadbod-ui só sabe montar a query do "List" (e New query/Table/etc)
      -- pra schemes com um template registrado em autoload/db_ui/table_helpers.vim
      -- (postgres, mysql, sqlite...). "db2" é um adaptador nosso, não tem
      -- entrada lá, então cai num template vazio e o "List" não faz nada.
      -- Isso aqui é o jeito suportado de registrar um (g:db_ui_table_helpers,
      -- ver doc/dadbod-ui.txt). DB2 não tem LIMIT, usa FETCH FIRST.
      -- "Colunas": metadados das colunas via catálogo SYSIBM.SYSCOLUMNS
      -- (nome, tipo, tamanho, nulidade, auto-geração/incremento via
      -- GENERATED_ATTR, valor padrão via DEFAULTVALUE e comentário via
      -- REMARKS). Nomes de alias sem acento de propósito, pra não arriscar
      -- mojibake no meio do pipe JDBC/sqlline/terminal.
      local db2_colunas_query = table.concat({
        "SELECT",
        "  NAME AS COLUNA,",
        "  COLNO AS NUM,",
        "  COLTYPE AS TIPO,",
        "  LENGTH AS COMPRIMENTO,",
        "  SCALE AS ESCALA,",
        "  CASE WHEN NULLS = 'N' THEN 'S' ELSE 'N' END AS NAO_NULO,",
        "  CASE WHEN GENERATED_ATTR IN ('A', 'D', 'E', 'R') THEN 'S' ELSE 'N' END AS AUTO_GERADO,",
        "  CASE WHEN GENERATED_ATTR IN ('A', 'D') THEN 'S' ELSE 'N' END AS AUTO_INCREMENTO,",
        "  DEFAULTVALUE AS PADRAO,",
        "  REMARKS AS DESCRICAO",
        "FROM SYSIBM.SYSCOLUMNS",
        "WHERE TBNAME = '{table}' AND TBCREATOR = '{schema}'",
        "ORDER BY COLNO",
        "FETCH FIRST 500 ROWS ONLY;",
      }, "\n")

      -- "Chaves": chave primária (SYSINDEXES/SYSKEYS, UNIQUERULE='P') e
      -- chaves estrangeiras (SYSFOREIGNKEYS/SYSRELS, com a tabela
      -- referenciada). RESTRICAO é o nome interno do índice/relacionamento
      -- no catálogo — serve pra agrupar as colunas de uma mesma chave
      -- composta (SEQ) quando há mais de uma FK na tabela.
      local db2_chaves_query = table.concat({
        "SELECT 'PK' AS TIPO, K.COLNAME AS COLUNA, K.COLSEQ AS SEQ, I.NAME AS RESTRICAO, '' AS TABELA_REF",
        "FROM SYSIBM.SYSINDEXES I",
        "JOIN SYSIBM.SYSKEYS K ON K.IXNAME = I.NAME AND K.IXCREATOR = I.CREATOR",
        "WHERE I.TBNAME = '{table}' AND I.TBCREATOR = '{schema}' AND I.UNIQUERULE = 'P'",
        "UNION ALL",
        "SELECT 'FK' AS TIPO, FK.COLNAME AS COLUNA, FK.COLSEQ AS SEQ, FK.RELNAME AS RESTRICAO,",
        "  R.REFTBCREATOR || '.' || R.REFTBNAME AS TABELA_REF",
        "FROM SYSIBM.SYSFOREIGNKEYS FK",
        "JOIN SYSIBM.SYSRELS R ON R.RELNAME = FK.RELNAME AND R.CREATOR = FK.CREATOR",
        "WHERE FK.TBNAME = '{table}' AND FK.CREATOR = '{schema}'",
        "ORDER BY 1, 4, 3;",
      }, "\n")

      vim.g.db_ui_table_helpers = {
        db2 = {
          List = "SELECT * FROM {optional_schema}{table} FETCH FIRST 200 ROWS ONLY;",
          Colunas = db2_colunas_query,
          Chaves = db2_chaves_query,
        },
      }
    end,
    config = function()
      -- Autocomplete de tabela/coluna specific do buffer conectado, integrado
      -- ao nvim-cmp já usado no resto da config.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          })
        end,
      })

      -- Cabeçalho fixo no resultado da query: o adaptador do DB2 formata os
      -- resultados como tabela ASCII (autoload/db/adapter/db2.vim, ver
      -- --outputformat=table), com duas linhas de borda "+---+---+"
      -- ao redor do nome das colunas. Detecta essas bordas e abre um split
      -- de topo mostrando só o cabeçalho, parado, enquanto o resultado
      -- embaixo rola livremente — não tem "freeze pane" nativo no Vim, isso
      -- simula com uma segunda janela pra mesma buffer.
      -- Sincroniza só a rolagem HORIZONTAL (leftcol) da janela de resultado
      -- pra janela do cabeçalho fixo, sem usar 'scrollbind' — esse também
      -- sincronizaria a vertical (a linha do cabeçalho não pode se mover) e
      -- é opção global ('scrollopt'), afetaria até o scrollbind do diffview.
      local dbout_sync_main_win, dbout_sync_header_win

      local function sync_dbout_header_scroll(main_win)
        if not dbout_sync_header_win or main_win ~= dbout_sync_main_win then
          return
        end
        if not vim.api.nvim_win_is_valid(dbout_sync_header_win) then
          dbout_sync_main_win, dbout_sync_header_win = nil, nil
          return
        end
        local leftcol = vim.api.nvim_win_call(main_win, function()
          return vim.fn.winsaveview().leftcol
        end)
        vim.api.nvim_win_call(dbout_sync_header_win, function()
          vim.fn.winrestview({ leftcol = leftcol })
        end)
      end

      vim.api.nvim_create_autocmd("WinScrolled", {
        callback = function(args)
          sync_dbout_header_scroll(tonumber(args.match))
        end,
      })

      local function freeze_dbout_header()
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 20, false)

        local borders = {}
        for lnum, line in ipairs(lines) do
          if line:match("^%+[-+]+%+%s*$") then
            table.insert(borders, lnum)
            if #borders == 2 then
              break
            end
          end
        end
        if #borders < 2 then
          return
        end
        local header_start = borders[1]
        local header_height = borders[2] - header_start + 1

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.w[win].dbout_header_freeze then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end

        local main_win = vim.api.nvim_get_current_win()
        -- "aboveleft" (não "topleft"): precisa ficar restrito à coluna da
        -- janela de resultado. "topleft" abre relativo à aba inteira e
        -- empurra até a barra lateral do drawer do :DBUI pra baixo.
        vim.cmd("aboveleft " .. header_height .. "split")
        local header_win = vim.api.nvim_get_current_win()
        vim.w[header_win].dbout_header_freeze = true
        vim.wo[header_win].winfixheight = true
        vim.wo[header_win].cursorline = false
        -- ftplugin/dbout.vim do próprio plugin liga fold (foldmethod=expr)
        -- pra agrupar os resultados; como é opção local à janela, o split
        -- herda o fold da janela original e mostra o cabeçalho recolhido
        -- ("+-- 3 lines: ...") em vez do conteúdo. Desliga só aqui.
        vim.wo[header_win].foldenable = false
        -- pula qualquer ruído antes da 1ª borda (ex: aviso do jline no db2),
        -- deixando só a tabela (borda/coluna/borda) visível no topo.
        vim.api.nvim_win_set_cursor(header_win, { header_start, 0 })
        vim.api.nvim_win_call(header_win, function()
          vim.cmd("normal! zt")
        end)
        vim.api.nvim_set_current_win(main_win)

        dbout_sync_main_win, dbout_sync_header_win = main_win, header_win
      end

      -- Direto, sem vim.schedule: o db.vim (s:query_callback) volta o foco
      -- pra janela original logo depois do "edit!" que dispara esse
      -- BufReadPost, então adiar a execução pegaria o buffer errado.
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.dbout",
        callback = freeze_dbout_header,
      })
    end,
  },
}
