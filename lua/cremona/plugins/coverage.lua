-- Cobertura de teste (jacoco) sob demanda: ,tv na classe atual mostra/esconde
-- as marcações de linha coberta/parcial/não-coberta no gutter.
--
-- O loader Java embutido no plugin depende de neotest (só pra parsear XML) —
-- pesado demais só por isso, e nem está instalado nesse config. Trocado por
-- um loader próprio em lua/coverage/languages/java.lua (sobrepõe o do plugin
-- via prioridade do runtimepath, mesma técnica do autoload/db_ui/schemas.vim
-- pro DB2), que também resolve o jacoco.xml certo por módulo Maven (naf-web é
-- multi-módulo: ejb/, batch/, assinador/, web/, cada um com seu próprio
-- target/site/jacoco/jacoco.xml).
--
-- Precisa rodar ,tc ou ,tt primeiro nesse módulo pra gerar/atualizar o
-- jacoco.xml -- ,tv só lê o que já foi gerado, não roda teste nenhum.
return {
  "andythigpen/nvim-coverage",
  ft = "java",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("coverage").setup()

    local function toggle_java_coverage()
      local coverage = require("coverage")
      if require("coverage.signs").is_enabled() then
        coverage.hide()
      else
        coverage.load(true)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function(args)
        vim.keymap.set("n", ",tv", toggle_java_coverage, {
          buffer = args.buf,
          desc = "Mostrar/esconder cobertura de teste (jacoco) da classe atual",
        })
      end,
    })
  end,
}
