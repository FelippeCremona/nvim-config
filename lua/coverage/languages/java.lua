-- Location: lua/coverage/languages/java.lua
--
-- Shadow do loader Java do andythigpen/nvim-coverage (lua/coverage/languages/java.lua
-- de dentro do plugin). O daqui de ~/.config/nvim tem prioridade no
-- runtimepath e sobrepõe o do plugin (mesma técnica usada em
-- autoload/db_ui/schemas.vim pro adaptador do DB2).
--
-- Reescrito porque o loader original depende de plenary.Path e principalmente
-- de neotest.lib.xml (só pra fazer parse de XML) — neotest não está instalado
-- nesse config e seria um plugin pesado só de carona por causa disso. Como o
-- jacoco.xml é sempre gerado numa estrutura previsível, um parser via padrão
-- Lua simples resolve sem essas dependências.
--
-- Também resolve o caminho do jacoco.xml e o dir_prefix DINAMICAMENTE a
-- partir do módulo Maven do buffer atual (naf-web é multi-módulo: ejb/,
-- batch/, assinador/, web/, cada um com seu próprio target/site/jacoco/jacoco.xml),
-- em vez do caminho fixo relativo que o plugin original assume (projeto
-- single-module).

local M = {}

local cs = require("coverage.signs")

-- Acha o pom.xml do módulo Maven mais próximo do buffer atual. Reaproveita a
-- mesma lógica do java_test_runner.lua (,tm/,tc/,tD) em vez de duplicar.
local function find_module_dir()
  local ok, runner = pcall(require, "cremona.java_test_runner")
  if not ok then
    return nil
  end
  local module_dir = runner.find_maven_dirs(vim.fn.expand("%:p:h"))
  return module_dir
end

-- Faz parse do jacoco.xml (formato sempre em uma linha só, gerado pelo
-- próprio jacoco): <package name="a/b"><sourcefile name="Foo.java">
-- <line nr="N" mi="M" ci="C" mb="MB" cb="CB"/>...</sourcefile></package>
-- mi/ci = instruções perdidas/cobertas; mb/cb = branches perdidos/cobertos.
local function parse_jacoco_xml(xml_path)
  local ok, lines = pcall(vim.fn.readfile, xml_path)
  if not ok then
    return nil
  end
  local content = table.concat(lines, "")

  -- rel_path ("pacote/Arquivo.java") -> { lines = {[nr]=status}, covered=N, missed=N }
  local files = {}

  for package_name, package_body in content:gmatch('<package name="([^"]+)">(.-)</package>') do
    for src_name, src_body in package_body:gmatch('<sourcefile name="([^"]+)">(.-)</sourcefile>') do
      local rel_path = package_name .. "/" .. src_name
      local file_data = { lines = {}, covered = 0, missed = 0 }

      for nr, mi, ci, mb, cb in src_body:gmatch('<line nr="(%d+)" mi="(%d+)" ci="(%d+)" mb="(%d+)" cb="(%d+)"') do
        nr, mi, ci, mb, cb = tonumber(nr), tonumber(mi), tonumber(ci), tonumber(mb), tonumber(cb)
        local status
        if (mb > 0 and cb > 0) or (mi > 0 and ci > 0) then
          status = "partial"
        elseif mb > 0 or mi > 0 then
          status = "missed"
          file_data.missed = file_data.missed + 1
        else
          status = "covered"
          file_data.covered = file_data.covered + 1
        end
        file_data.lines[nr] = status
      end

      files[rel_path] = file_data
    end
  end

  return files
end

--- Carrega o relatório de cobertura do módulo Maven do buffer atual.
-- @param callback chamado com os dados do relatório
M.load = function(callback)
  local module_dir = find_module_dir()
  if not module_dir then
    vim.notify("Coverage: pom.xml não encontrado a partir do arquivo atual", vim.log.levels.WARN)
    return
  end

  local xml_path = module_dir .. "/target/site/jacoco/jacoco.xml"
  if vim.fn.filereadable(xml_path) == 0 then
    vim.notify(
      "Coverage: " .. xml_path .. " não existe — rode ,tc ou ,tt nesse módulo primeiro",
      vim.log.levels.WARN
    )
    return
  end

  local parsed = parse_jacoco_xml(xml_path)
  if not parsed then
    vim.notify("Coverage: falha ao ler " .. xml_path, vim.log.levels.ERROR)
    return
  end

  local src_root = module_dir .. "/src/main/java/"
  local data = { files = {}, totals = { covered = 0, missed = 0 } }
  for rel_path, file_data in pairs(parsed) do
    local abs_path = src_root .. rel_path
    data.files[abs_path] = file_data
    data.totals.covered = data.totals.covered + file_data.covered
    data.totals.missed = data.totals.missed + file_data.missed
  end

  callback(data)
end

--- Lista de signs a colocar nos buffers já abertos.
M.sign_list = function(data)
  local signs = {}
  local funcs = {
    covered = cs.new_covered,
    partial = cs.new_partial,
    missed = cs.new_uncovered,
  }
  for filename, file_data in pairs(data.files) do
    local bufnr = vim.fn.bufnr(filename, false)
    if bufnr ~= -1 then
      for lnum, status in pairs(file_data.lines) do
        table.insert(signs, funcs[status](bufnr, lnum))
      end
    end
  end
  return signs
end

--- Relatório resumido (usado pelo :CoverageSummary).
M.summary = function(data)
  local report = { files = {} }
  for filename, file_data in pairs(data.files) do
    local statements = file_data.covered + file_data.missed
    local coverage = statements == 0 and 100 or (file_data.covered / statements) * 100
    table.insert(report.files, {
      filename = filename,
      statements = statements,
      missing = file_data.missed,
      branches = 0,
      partial = 0,
      coverage = coverage,
    })
  end

  local total_statements = data.totals.covered + data.totals.missed
  report.totals = {
    statements = total_statements,
    missing = data.totals.missed,
    branches = 0,
    partial = 0,
    coverage = total_statements == 0 and 100 or (data.totals.covered / total_statements) * 100,
  }

  return report
end

return M
