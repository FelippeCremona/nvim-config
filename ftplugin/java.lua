-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.

require("cremona.java_test_runner").setup()

local home = os.getenv("HOME")
local mason_path = vim.fn.stdpath("data") .. "/mason/"

-- jdtls instalado via mason (:MasonInstall jdtls). O wrapper "jdtls" resolve
-- sozinho o launcher/config por SO; só precisamos apontar -data e o agente
-- do lombok. O jdt.ls moderno exige Java 21 pra rodar o próprio servidor
-- (independente da versão do projeto), por isso o JAVA_HOME abaixo.
local jdtls_bin = mason_path .. "packages/jdtls/jdtls"
local lombok_path = mason_path .. "packages/jdtls/lombok.jar"
local jdtls_java_home = home .. "/.sdkman/candidates/java/21.0.2-open"

local root_markers = { ".git" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
  return
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

WORKSPACE_PATH = home .. "/trabalho/workspace/"
local workspace_dir = WORKSPACE_PATH .. project_name

local bundles = {}

-- IMPORTANTE: java-test precisa ficar fixado em 0.39.0
-- (:MasonInstall java-test@0.39.0). Versões mais novas (0.43.1+) exigem
-- org.objectweb.asm na faixa [9.9.0,9.10.0), mas o jdtls (v1.60.0+) só traz
-- 9.10.1 embutido — fora da faixa — e isso quebra a ativação do bundle
-- (Run Test/Debug Test somem). A 0.39.0 não depende de asm, então funciona
-- limpo com o jdtls atual. Rodar ":MasonUpdate" sem essa ressalva volta pra
-- versão nova e quebra de novo; se acontecer, reinstale a 0.39.0.
--
-- jacocoagent.jar e o *-jar-with-dependencies.jar não são bundles OSGi
-- válidos (não têm MANIFEST.MF de plugin). Incluí-los na lista faz o
-- carregamento do lote inteiro de bundles falhar no jdtls (CoreException:
-- Load bundle list), o que impede até os bundles válidos (como o do
-- java-debug-adapter) de serem ativados.
local java_test_jars = vim.split(vim.fn.glob(mason_path .. "packages/java-test/extension/server/*.jar"), "\n")
java_test_jars = vim.tbl_filter(function(jar)
  return not jar:match("jacocoagent%.jar$") and not jar:match("%-jar%-with%-dependencies%.jar$")
end, java_test_jars)
vim.list_extend(bundles, java_test_jars)

vim.list_extend(
  bundles,
  vim.split(
    vim.fn.glob(mason_path .. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
    -- vim.fn.glob("/home/cremona/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*"),
    "\n"
  )
)


require('dap').set_log_level('DEBUG')

-- Main Config
local config = {
  -- The command that starts the language server
  cmd = {
    jdtls_bin,
    '--jvm-arg=-javaagent:' .. lombok_path,
    '-data', workspace_dir,
  },

  -- JVM que roda o próprio jdt.ls (não é a JDK do projeto, essa vem de
  -- settings.java.configuration.runtimes abaixo).
  cmd_env = {
    JAVA_HOME = jdtls_java_home,
  },

  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      home = '~/.sdkman/candidates/java/11.0.2-open',
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-17",
            path = "~/.sdkman/candidates/java/17-open",
          },
          {
            name = "JavaSE-19",
            path = "~/.sdkman/candidates/java/19-open",
          },
          {
            name = "JavaSE-11",
            path = "~/.sdkman/candidates/java/11.0.2-open",
          },
          {
            name = "JavaSE-1.8",
            path = home .. "/trabalho/programas/java/jdk1.8.0_351",
          }
        }
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = false,
      },
      referencesCodeLens = {
        enabled = false,
      },
      references = {
        includeDecompiledSources = true,
      },
      format = {
        enabled = false,
        settings = {
          url = vim.fn.stdpath "config" .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      -- Diferente de implementations/referencesCodeLens, calcular esses hints
      -- é barato (só olha os argumentos literais da chamada visível, sem
      -- busca no workspace), então deixamos a setting do servidor sempre
      -- ligada; quem controla se aparece na tela é o toggle client-side
      -- (,cl, mais abaixo) via vim.lsp.inlay_hint.enable().
      inlayHints = {
        parameterNames = {
          enabled = "literals",
        },
      },

    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
      importOrder = {
        "java",
        "javax",
        "com",
        "org"
      },
    },
    -- extendedClientCapabilities = extendedClientCapabilities,
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
      useBlocks = true,
    },
  },

  flags = {
    allow_incremental_sync = true,
  },
  init_options = {
    bundles = bundles,
  },
}

config['on_attach'] = function(client, _)
  -- on_attach dispara mais de uma vez pro mesmo cliente jdtls (uma vez por
  -- buffer que anexa, às vezes mais de uma vez pro mesmo buffer). Sem essa
  -- guarda, cada disparo repete o scan de classes main() do projeto inteiro
  -- (causando a enxurrada de "Could not resolve classpath...") e duplica a
  -- entrada "Attach ao JBoss". Guardamos numa flag no próprio cliente, que é
  -- reaproveitado entre arquivos do mesmo projeto, pra rodar isso só uma vez.
  if client.jdtls_dap_configured then
    return
  end
  client.jdtls_dap_configured = true

  require("jdtls").setup_dap({ hotcodereplace = "auto" })

  -- Sem "projectName", o java-debug-adapter não consegue avaliar expressões
  -- (variável/watch/REPL) num workspace multi-módulo: dá
  -- "Cannot evaluate ... please specify projectName in launch.json" — ele
  -- precisa saber contra qual módulo (projeto Eclipse importado pelo jdtls)
  -- compilar a expressão. Resolve pelo caminho do buffer ATUAL no momento em
  -- que a sessão de debug é iniciada (nvim-dap aceita função em qualquer
  -- campo da config e resolve na hora do launch — não é reavaliado depois,
  -- por isso "atual" aqui significa "onde você estava ao dar start no debug").
  -- Nomes dos projetos Eclipse conferidos em
  -- ~/trabalho/workspace/naf-web/.metadata/.../.projects/.
  local function resolve_project_name()
    local path = vim.api.nvim_buf_get_name(0)
    local module_to_project = {
      ['/ejb/'] = 'sinaf-ejb',
      ['/web/'] = 'sinaf3-web',
      ['/batch/'] = 'sinaf-batch',
      ['/assinador/'] = 'sinaf-assinador',
      ['/ear/'] = 'sinaf-ear',
    }
    for module_dir, project_name in pairs(module_to_project) do
      if path:find(module_dir, 1, true) then
        return project_name
      end
    end
    return 'sinaf-ejb'
  end

  -- Anexa numa JVM já rodando (ex: JBoss iniciado com o agente JDWP
  -- escutando na porta 5005), usando o adaptador dinâmico do jdtls em vez
  -- de um adaptador cru fixo.
  local dap = require('dap')
  dap.configurations.java = dap.configurations.java or {}
  table.insert(dap.configurations.java, {
    type = 'java',
    request = 'attach',
    name = 'Attach ao JBoss (porta 5005)',
    hostName = '127.0.0.1',
    port = 5005,
    projectName = resolve_project_name,
  })

  -- Anexa na JVM de teste que o ,tD (java_test_runner.lua) sobe pausada
  -- (surefire com suspend=y) esperando o debugger nessa porta.
  local test_debug_port = require("cremona.java_test_runner").TEST_DEBUG_PORT
  table.insert(dap.configurations.java, {
    type = 'java',
    request = 'attach',
    name = string.format('Debug teste (porta %d)', test_debug_port),
    hostName = '127.0.0.1',
    port = test_debug_port,
    projectName = resolve_project_name,
  })

  require("jdtls.dap").setup_dap_main_class_configs()

  -- Não dá pra usar require("jdtls.dap").test_nearest_method()/test_class()
  -- (o run/debug de teste nativo do jdtls) agora: nenhuma versão publicada
  -- do java-test é compatível com esse jdt.ls. A 0.43.1 falha ao ativar o
  -- bundle (exige org.objectweb.asm em [9.9.0,9.10.0), o jdtls só traz
  -- 9.10.1). A 0.39.0 (fixada acima) ativa, mas o comando de busca de teste
  -- quebra em runtime (referencia uma classe interna do jdt.ls que não
  -- existe mais: org.eclipse.jdt.ls.core.internal.hover.JavaElementLabels).
  -- Pra rodar/debugar teste, usar ,tm/,tc/,tt (mvn via tmux) e o "Attach ao
  -- JBoss" acima.
end

-- Sem isso o cliente nunca pede os CodeLens ao servidor (Run Test/Debug
-- Test, implementations, references ficam invisíveis mesmo com o bundle
-- do java-test funcionando).
--
-- Sem "CursorHold" de propósito: com updatetime=40 (lua/cremona/core/options.lua),
-- esse evento dispara a cada pausa mínima do cursor, e cada refresh de
-- referencesCodeLens busca referências no workspace inteiro por método
-- visível — isso sobrecarregava o jdtls e deixava até gd/gi lentos.
--
-- implementations/referencesCodeLens ficam desligados nas settings acima por
-- padrão pelo mesmo motivo: mesmo só nesses 3 eventos (não CursorHold), o
-- jdtls recalcula referência/implementação de todo método visível no buffer
-- a cada BufEnter/InsertLeave/BufWritePost, e isso é caro no workspace real.
-- toggle_java_codelens() liga essas duas settings via
-- workspace/didChangeConfiguration só quando pedido, e o autocmd abaixo só
-- dispara refresh se vim.b.java_codelens_on estiver true NESTE buffer — como
-- cada buffer Java tem seu próprio autocmd (buffer=0 no momento da criação),
-- outros arquivos abertos não são afetados mesmo com a setting ligada no
-- cliente (que é compartilhado por todos os buffers do mesmo projeto).
local function set_java_codelens_setting(client, enabled)
  client.config.settings.java.implementationsCodeLens.enabled = enabled
  client.config.settings.java.referencesCodeLens.enabled = enabled
  client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
end

local function toggle_java_codelens()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'jdtls' })
  if vim.tbl_isempty(clients) then
    return
  end
  local client = clients[1]

  if vim.b.java_codelens_on then
    vim.b.java_codelens_on = false
    set_java_codelens_setting(client, false)
    vim.lsp.codelens.clear(client.id, bufnr)
    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    vim.notify('Java CodeLens + inlay hints desativados', vim.log.levels.INFO)
  else
    vim.b.java_codelens_on = true
    set_java_codelens_setting(client, true)
    vim.lsp.codelens.refresh({ bufnr = bufnr })
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    vim.notify('Java CodeLens + inlay hints ativados (só nesta classe)', vim.log.levels.INFO)
  end
end

vim.keymap.set('n', ',cl', toggle_java_codelens, { buffer = 0, silent = true, desc = 'Toggle Java CodeLens (references/implementations) + inlay hints (nomes de parâmetro)' })

vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
  buffer = 0,
  callback = function()
    if vim.b.java_codelens_on then
      pcall(vim.lsp.codelens.refresh, { bufnr = 0 })
    end
  end,
})

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
