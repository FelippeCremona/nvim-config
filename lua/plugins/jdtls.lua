local jdtls_path = "/home/cremona/trabalho/programas/jdtls"
local path_to_lsp_server = jdtls_path .. "/config_linux"
local path_to_plugins = jdtls_path .. "/plugins/"
local path_to_jar = path_to_plugins .. "org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar"
local lombok_path = jdtls_path .. "/lombok.jar"

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
WORKSPACE_PATH = os.getenv("HOME") .. "/trabalho/workspace/"
local workspace_dir = WORKSPACE_PATH .. project_name

require('dap').configurations.java = {
  {
    type = 'java';
    request = 'attach';
    name = "Debug (Attach) - Remote";
    hostName = "127.0.0.1";
    port = 5005;
  },
}

require'lspconfig'.jdtls.setup{
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-javaagent:' .. lombok_path,
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    '-jar', path_to_jar,
    '-configuration', path_to_lsp_server,
    '-data', workspace_dir,
  },
  -- filetypes = {"odd!"}
  --
  --   -- This is the default if not provided, you can remove it. Or adjust as needed.
  --   -- One dedicated LSP server & client will be started per unique root_dir
  -- root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      autobuild = false,
      typeHierarchy = {
        lazy_load = true
      },
      server = {
        launchMode = "LightWeight"
      },
      home = '~/.sdkman/candidates/java/11.0.2-open',
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-11",
            path = "~/.sdkman/candidates/java/11.0.17-tem",
          },
          {
            name = "JavaSE-18",
            path = "~/.sdkman/candidates/java/18.0.2-sem",
          },
        },
      },
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

    },
    signatureHelp = { enabled = true },
    -- completion = {
    --   favoriteStaticMembers = {
    --     "org.hamcrest.MatcherAssert.assertThat",
    --     "org.hamcrest.Matchers.*",
    --     "org.hamcrest.CoreMatchers.*",
    --     "org.junit.jupiter.api.Assertions.*",
    --     "java.util.Objects.requireNonNull",
    --     "java.util.Objects.requireNonNullElse",
    --     "org.mockito.Mockito.*",
    --   },
    --   importOrder = {
    --     "java",
    --     "javax",
    --     "com",
    --     "org"
    --   },
    -- },
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
    bundles = {},
    -- bundles = bundles,
  },
}
