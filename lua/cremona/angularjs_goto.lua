-- lua/cremona/angularjs_goto.lua
--
-- Simula "go to definition" pra código AngularJS 1.x, já que a injeção de
-- dependência por string desse projeto não deixa o ts_ls/html resolver isso.
--
-- ,gd (arquivo .js): chamadas de serviço tipo processoService.recupera(id).
-- Convenção: variável "processoService" (camelCase) -> arquivo
-- "ProcessoService.js" (PascalCase), método exposto como
-- "function nome(params) { ... }" dentro dele.
--
-- ,gc (arquivo .html): acha o controller associado à view atual procurando
-- a definição de rota do ui-router (templateUrl + controller), e se o
-- cursor estiver em cima de "vm.algumaCoisa"/"vm.metodo(...)" pula direto
-- pra definição dentro do controller.
--
-- ,gr (arquivo .js, dentro de um método que chama $http): acha o endpoint
-- Java correspondente. Convenção: o trecho de URL em "url: url + 'segmento'"
-- aparece literalmente dentro de "@Path("/segmento")" no lado Java.

local M = {}

local function capitalize(s)
  return s:sub(1, 1):upper() .. s:sub(2)
end

local function count_params(param_str)
  local trimmed = param_str:match("^%s*(.-)%s*$")
  if trimmed == "" then
    return 0
  end
  local count = 1
  for _ in trimmed:gmatch(",") do
    count = count + 1
  end
  return count
end

-- Conta argumentos de uma chamada tipo vm.metodo('a, b', c) sem se confundir
-- com vírgulas dentro de strings.
local function count_call_args(args_str)
  local trimmed = args_str:match("^%s*(.-)%s*$")
  if trimmed == "" then
    return 0
  end
  local count = 1
  local in_quote = nil
  for i = 1, #trimmed do
    local c = trimmed:sub(i, i)
    if in_quote then
      if c == in_quote then
        in_quote = nil
      end
    elseif c == "'" or c == '"' then
      in_quote = c
    elseif c == "," then
      count = count + 1
    end
  end
  return count
end

local function project_search_root()
  local buf_dir = vim.fn.expand("%:p:h")
  local pkg = vim.fs.find({ "package.json" }, { upward = true, path = buf_dir })[1]
  local project_root = pkg and vim.fn.fnamemodify(pkg, ":h") or vim.fn.getcwd()

  local search_root = project_root .. "/src"
  if vim.fn.isdirectory(search_root) == 0 then
    search_root = project_root
  end
  return search_root
end

-- Procura declarações do método/propriedade no arquivo, nos formatos mais
-- comuns desse código: "function nome(a, b)", "nome: function(a, b)",
-- "nome = function(a, b)", "vm.nome = ..." (propriedade simples).
local function find_method_candidates(filepath, method_name)
  local ok, lines = pcall(vim.fn.readfile, filepath)
  if not ok then
    return {}
  end

  -- Convenção comum nesse código: vm.nome = _nome; ... function _nome() {...}
  -- (implementação com underscore, exposta com o nome limpo). Só tenta a
  -- variante com "_" se não achar nada com o nome exato.
  local name_variants = { method_name, "_" .. method_name }

  for _, name in ipairs(name_variants) do
    local name_pat = vim.pesc(name)
    local patterns = {
      "function%s+" .. name_pat .. "%s*%(([^%)]*)%)",
      name_pat .. "%s*[:=]%s*function%s*%(([^%)]*)%)",
    }

    local candidates = {}
    for lnum, line in ipairs(lines) do
      for _, pat in ipairs(patterns) do
        local params = line:match(pat)
        if params then
          local col = line:find(name_pat, 1, true) or 1
          table.insert(candidates, { lnum = lnum, col = col, params = count_params(params) })
          break
        end
      end
    end

    if #candidates > 0 then
      return candidates
    end
  end

  return {}
end

-- Propriedades simples (sem function), ex: vm.totalRegistros = 0; ou dentro
-- de um sub-objeto, vm.view.dataReferencia = null; (não exige o prefixo
-- exato "alias.", só que termine em ".nome =", pra cobrir os dois casos).
local function find_property_candidates(filepath, alias, property_name)
  local ok, lines = pcall(vim.fn.readfile, filepath)
  if not ok then
    return {}
  end

  local pat = "%." .. vim.pesc(property_name) .. "%s*="
  local col_pat = vim.pesc(property_name)
  local candidates = {}
  for lnum, line in ipairs(lines) do
    if line:match(pat) then
      local col = line:find(col_pat, 1, true) or 1
      table.insert(candidates, { lnum = lnum, col = col })
    end
  end
  return candidates
end

local function find_file_by_name(filename)
  local found = vim.fs.find(function(name)
    return name == filename
  end, { path = project_search_root(), limit = 1, type = "file" })

  return found[1]
end

-- Acha o arquivo que registra um serviço/factory/controller pelo nome real
-- (ex: .service('RN022', ...)), pra quando o nome do arquivo não bate com
-- esse nome de registro.
local function find_file_registering_service(name)
  local search_root = project_search_root()
  local rg_ok, rg_out = pcall(vim.fn.systemlist, {
    "rg", "-l", "--glob", "*.js",
    "\\.(service|factory|controller|value|constant)\\(['\"]" .. name .. "['\"]",
    search_root,
  })
  if rg_ok and vim.v.shell_error <= 1 and rg_out[1] then
    return rg_out[1]
  end
  return nil
end

-- Alguns serviços são injetados com um nome de parâmetro local que não bate
-- com o nome real registrado no Angular, ex:
--   DleRegras.$inject = ['RN023', 'RN026', 'RN180', 'RN022'];
--   function DleRegras(regra023, regra026, regra180, regras022) { ... }
-- Aqui "regras022" (nome local) na verdade é o serviço "RN022" (4ª posição
-- do $inject, mesma posição do parâmetro na function). Acha esse nome real
-- procurando, no buffer inteiro, uma "function NOME(params)" que tenha
-- local_param_name entre os parâmetros, e o "NOME.$inject = [...]"
-- correspondente, pegando a string na mesma posição.
local function resolve_injected_service_name(bufnr, local_param_name)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for _, line in ipairs(lines) do
    local fname, params = line:match("function%s+([%w_]+)%s*%(([^%)]*)%)")
    if fname and params then
      local idx, i = nil, 0
      for p in (params .. ","):gmatch("([^,]*),") do
        i = i + 1
        if p:match("^%s*(.-)%s*$") == local_param_name then
          idx = i
          break
        end
      end

      if idx then
        local inject_pat = vim.pesc(fname) .. "%.%$inject%s*=%s*%[(.-)%]"
        for _, l2 in ipairs(lines) do
          local arr = l2:match(inject_pat)
          if arr then
            local names, n = {}, 0
            for name in arr:gmatch("['\"]([^'\"]+)['\"]") do
              n = n + 1
              names[n] = name
            end
            if names[idx] then
              return names[idx]
            end
          end
        end
      end
    end
  end

  return nil
end

function M.goto_service_method()
  local ok_parser, parser = pcall(vim.treesitter.get_parser, 0)
  if ok_parser and parser then
    parser:parse()
  end

  local node = vim.treesitter.get_node()
  if not node or node:type() ~= "property_identifier" then
    vim.notify("Posicione o cursor no nome do método (ex: service.metodo)", vim.log.levels.WARN)
    return
  end

  local member = node:parent()
  if not member or member:type() ~= "member_expression" then
    vim.notify("Não é uma chamada no formato service.metodo(...)", vim.log.levels.WARN)
    return
  end

  local object_node = member:field("object")[1]
  if not object_node then
    vim.notify("Não achei o objeto antes do método", vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local arg_count = 0
  local call = member:parent()
  if call and call:type() == "call_expression" and call:field("function")[1] == member then
    local args = call:field("arguments")[1]
    if args then
      arg_count = args:named_child_count()
    end
  end

  local service_name = vim.treesitter.get_node_text(object_node, bufnr)
  local method_name = vim.treesitter.get_node_text(node, bufnr)

  local resolved_name = resolve_injected_service_name(bufnr, service_name)
  local filepath, filename

  if resolved_name then
    filename = resolved_name .. ".js"
    filepath = find_file_by_name(filename) or find_file_registering_service(resolved_name)
  end

  if not filepath then
    filename = capitalize(service_name) .. ".js"
    filepath = find_file_by_name(filename)
  end

  if not filepath then
    vim.notify('Arquivo "' .. filename .. '" não encontrado no projeto', vim.log.levels.WARN)
    return
  end

  local candidates = find_method_candidates(filepath, method_name)
  if #candidates == 0 then
    vim.notify('Método "' .. method_name .. '" não encontrado em ' .. filename, vim.log.levels.WARN)
    return
  end

  local target
  for _, c in ipairs(candidates) do
    if c.params == arg_count then
      target = c
      break
    end
  end

  if not target then
    target = candidates[1]
    vim.notify(
      string.format(
        '"%s" achado em %s, mas nenhuma versão com %d parâmetro(s) — indo pra 1ª ocorrência (%d parâmetro(s))',
        method_name,
        filename,
        arg_count,
        target.params
      ),
      vim.log.levels.WARN
    )
  end

  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  vim.api.nvim_win_set_cursor(0, { target.lnum, target.col - 1 })
  vim.cmd("normal! zvzz")
end

-- Acha, pra view HTML atual, o controller associado e o alias (controllerAs,
-- normalmente "vm") procurando a definição de rota do ui-router que
-- referencia esse arquivo em templateUrl.
local function find_controller_for_current_html()
  local basename = vim.fn.expand("%:t")
  local search_root = project_search_root()

  local rg_ok, rg_out = pcall(
    vim.fn.systemlist,
    { "rg", "-l", "-F", "--glob", "*.js", basename, search_root }
  )
  if not rg_ok or vim.v.shell_error > 1 then
    return nil
  end

  for _, filepath in ipairs(rg_out) do
    local ok, lines = pcall(vim.fn.readfile, filepath)
    if ok then
      for lnum, line in ipairs(lines) do
        if line:match("templateUrl") and line:find(basename, 1, true) then
          local controller, controller_as
          for i = lnum, math.min(lnum + 8, #lines) do
            controller = controller or lines[i]:match("controller%s*:%s*['\"]([%w_.]+)['\"]")
            controller_as = controller_as or lines[i]:match("controllerAs%s*:%s*['\"]([%w_]+)['\"]")
            if controller then
              break
            end
          end
          if controller then
            return controller, controller_as or "vm"
          end
        end
      end
    end
  end

  return nil
end

-- Extrai o identificador sob o cursor de uma cadeia tipo
-- "alias.identificador(args)" ou "alias.sub.identificador(args)" (ex:
-- vm.metodo(...), vm.view.metodo(...)) na linha atual. Sempre retorna só o
-- ÚLTIMO segmento antes do cursor (o que faz sentido buscar no controller),
-- não a cadeia inteira.
local function html_cursor_context(alias)
  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local alias_pat = vim.pesc(alias)

  local chain_start, chain_end = line:find(alias_pat .. "%.[%w_.]+", 1)
  while chain_start do
    local seg_pos = chain_start
    while true do
      local s, e, name = line:find("%.([%w_]+)", seg_pos)
      if not s or s > chain_end then
        break
      end
      if cursor_col >= s + 1 and cursor_col <= e then
        local after = line:sub(e + 1)
        local args_str = after:match("^%s*%(([^%)]*)%)")
        local arg_count = args_str and count_call_args(args_str) or nil
        return name, arg_count
      end
      seg_pos = e + 1
    end
    chain_start, chain_end = line:find(alias_pat .. "%.[%w_.]+", chain_end + 1)
  end

  return nil
end

function M.goto_html_controller_member()
  local controller, alias = find_controller_for_current_html()
  if not controller then
    vim.notify("Não achei a rota (ui-router) que referencia essa view", vim.log.levels.WARN)
    return
  end

  local filename = controller:match("([^.]+)$") .. ".js"
  local filepath = find_file_by_name(filename)
  if not filepath then
    vim.notify('Controller "' .. controller .. '" -> arquivo "' .. filename .. '" não encontrado', vim.log.levels.WARN)
    return
  end

  local member_name, arg_count = html_cursor_context(alias)
  if not member_name then
    -- Sem o cursor em cima de algo tipo "vm.x", só abre o controller mesmo.
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
    vim.notify("Controller: " .. controller, vim.log.levels.INFO)
    return
  end

  local candidates = find_method_candidates(filepath, member_name)
  local target
  if #candidates > 0 then
    for _, c in ipairs(candidates) do
      if arg_count ~= nil and c.params == arg_count then
        target = c
        break
      end
    end
    target = target or candidates[1]
  end

  if not target and arg_count == nil then
    local prop_candidates = find_property_candidates(filepath, alias, member_name)
    target = prop_candidates[1]
  end

  if not target then
    vim.notify(
      '"' .. member_name .. '" não encontrado em ' .. filename .. " — abrindo o controller (" .. controller .. ")",
      vim.log.levels.WARN
    )
    vim.cmd("edit " .. vim.fn.fnameescape(filepath))
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  vim.api.nvim_win_set_cursor(0, { target.lnum, target.col - 1 })
  vim.cmd("normal! zvzz")
end

-- Range (linha inicial/final, 1-indexado) da function_declaration que
-- contém o cursor.
local function find_enclosing_function_range()
  local ok_parser, parser = pcall(vim.treesitter.get_parser, 0)
  if ok_parser and parser then
    parser:parse()
  end

  local node = vim.treesitter.get_node()
  while node do
    if node:type() == "function_declaration" then
      local start_row, _, end_row, _ = node:range()
      return start_row + 1, end_row + 1
    end
    node = node:parent()
  end

  return nil
end

-- Classifica a chamada $http no intervalo de linhas dado:
-- "literal": url : ... 'algum-texto' -> tem um trecho fixo pra casar com @Path.
-- "concat_var": url : url + id (concatena uma variável, sem texto fixo) ->
--   corresponde a um @Path que é só um placeholder, tipo "/{nuEntidade}".
-- "base": url : url (nada concatenado) -> corresponde ao método sem @Path
--   próprio, só o verbo HTTP (@GET etc) usando o @Path da classe.
local function classify_url_expression(start_line, end_line)
  for lnum = start_line, end_line do
    local line = vim.fn.getline(lnum)
    if line:match("url%s*:") then
      local literal = line:match("url%s*:.-'([^']+)'")
      if literal then
        literal = literal:gsub("^/+", ""):gsub("/+$", "")
        if literal ~= "" then
          return "literal", literal
        end
      end
      if line:match("url%s*:%s*url%s*%+%s*[%a_]") then
        return "concat_var"
      end
      if line:match("url%s*:%s*url%s*[,%s]*$") then
        return "base"
      end
      return "unknown"
    end
  end
  return nil
end

local HTTP_VERBS = { "GET", "POST", "PUT", "DELETE", "HEAD" }

local function extract_http_method(start_line, end_line)
  for lnum = start_line, end_line do
    local line = vim.fn.getline(lnum)
    local m = line:match("method%s*:%s*'([%u]+)'")
    if m then
      return m
    end
  end
  return nil
end

-- Segmento base declarado tipo: var url = appValue.rest + 'entidade/';
-- (geralmente uma vez perto do topo do arquivo, fora de qualquer função).
local function extract_base_segment(bufnr)
  local total = vim.api.nvim_buf_line_count(bufnr)
  for lnum = 1, total do
    local line = vim.fn.getbufline(bufnr, lnum)[1] or ""
    local seg = line:match("var%s+url%s*=.-'([^']+)'")
    if seg then
      seg = seg:gsub("^/+", ""):gsub("/+$", "")
      if seg ~= "" then
        return seg
      end
    end
  end
  return nil
end

-- Acha o arquivo .java cujo @Path de classe bate com esse segmento (ex:
-- "entidade" -> @Path("/entidade")). Não depende do nome do arquivo.
local function find_rest_resource_file_by_base_segment(base_segment)
  if not base_segment then
    return nil
  end
  local search_root = project_search_root()
  local candidates = { '@Path("/' .. base_segment .. '")', '@Path("' .. base_segment .. '")' }
  for _, needle in ipairs(candidates) do
    local rg_ok, rg_out =
      pcall(vim.fn.systemlist, { "rg", "-l", "-F", "--glob", "*.java", needle, search_root })
    if rg_ok and vim.v.shell_error <= 1 and rg_out[1] then
      return rg_out[1]
    end
  end
  return nil
end

-- Convenção alternativa: FooService.js -> FooRS.java.
local function find_rest_resource_file_by_name()
  local js_basename = vim.fn.expand("%:t")
  local rs_name = js_basename:gsub("Service%.js$", "RS.java")
  if rs_name == js_basename then
    return nil
  end
  return find_file_by_name(rs_name)
end

-- É comum vários métodos (POST/PUT/DELETE/GET) compartilharem o mesmo texto
-- de @Path (ex: "instancia-controle/unidade"), diferenciados só pelo verbo.
-- Por isso junta TODOS os candidatos que batem com o texto e, se souber o
-- verbo HTTP do lado JS, prioriza o que tem esse verbo do lado Java.
local function find_literal_in_file(filepath, segment, http_method)
  local ok, lines = pcall(vim.fn.readfile, filepath)
  if not ok then
    return nil
  end

  local candidates = {}
  for lnum, line in ipairs(lines) do
    if line:match("@Path") and line:find(segment, 1, true) then
      local col = line:find("@Path", 1, true) or 1
      table.insert(candidates, { lnum = lnum, col = col })
    end
  end

  if #candidates == 0 then
    return nil
  end

  if http_method then
    for _, c in ipairs(candidates) do
      local prev = lines[c.lnum - 1] or ""
      local nxt = lines[c.lnum + 1] or ""
      local verb_pat = "^%s*@" .. http_method .. "%s*$"
      if prev:match(verb_pat) or nxt:match(verb_pat) then
        return c.lnum, c.col
      end
    end
  end

  return candidates[1].lnum, candidates[1].col
end

local function find_literal_in_project(segment, http_method)
  local search_root = project_search_root()
  local rg_ok, rg_out =
    pcall(vim.fn.systemlist, { "rg", "-l", "-F", "--glob", "*.java", segment, search_root })
  if not rg_ok or vim.v.shell_error > 1 then
    return nil
  end
  for _, filepath in ipairs(rg_out) do
    local lnum, col = find_literal_in_file(filepath, segment, http_method)
    if lnum then
      return filepath, lnum, col
    end
  end
  return nil
end

-- Método cujo @Path é só um placeholder de parâmetro, tipo "/{nuEntidade}"
-- (sem nenhum texto fixo além disso) — corresponde a "url + variável" no JS.
local function find_path_param_only_method(filepath)
  local ok, lines = pcall(vim.fn.readfile, filepath)
  if not ok then
    return nil
  end
  for lnum, line in ipairs(lines) do
    local val = line:match('@Path%s*%(%s*"([^"]*)"')
    if val then
      local stripped = val:gsub("^/+", "")
      if stripped:match("^{[%w_]+}$") then
        local col = line:find("@Path", 1, true) or 1
        return lnum, col
      end
    end
  end
  return nil
end

-- Método com o verbo HTTP mas SEM @Path próprio (usa só o @Path da classe)
-- — corresponde a "url : url" sem concatenar nada no JS.
local function find_base_method(filepath, http_method)
  local ok, lines = pcall(vim.fn.readfile, filepath)
  if not ok then
    return nil
  end
  for lnum, line in ipairs(lines) do
    for _, verb in ipairs(HTTP_VERBS) do
      if line:match("^%s*@" .. verb .. "%s*$") and (not http_method or verb == http_method) then
        local prev = lines[lnum - 1] or ""
        local nxt = lines[lnum + 1] or ""
        if not prev:match("@Path") and not nxt:match("@Path") then
          local col = line:find("@" .. verb, 1, true) or 1
          return lnum, col
        end
      end
    end
  end
  return nil
end

-- Da função .js atual (que faz uma chamada $http), acha o endpoint Java
-- (@Path) correspondente no backend. Cobre três padrões desse projeto:
--   url : url + 'texto-fixo'   -> casa com @Path que contém "texto-fixo"
--   url : url + variavel       -> casa com @Path("/{algumNome}") (placeholder)
--   url : url                  -> casa com o verbo HTTP sem @Path próprio
function M.goto_rest_endpoint()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_line, end_line = find_enclosing_function_range()
  if not start_line then
    vim.notify("Posicione o cursor dentro de um método que faz uma chamada $http", vim.log.levels.WARN)
    return
  end

  local kind, segment = classify_url_expression(start_line, end_line)
  if not kind then
    vim.notify("Não achei uma URL de chamada $http nesse método", vim.log.levels.WARN)
    return
  end

  local base_segment = extract_base_segment(bufnr)
  local rs_file = find_rest_resource_file_by_base_segment(base_segment) or find_rest_resource_file_by_name()
  local http_method = extract_http_method(start_line, end_line)

  local filepath, lnum, col

  if kind == "literal" then
    if rs_file then
      lnum, col = find_literal_in_file(rs_file, segment, http_method)
      filepath = lnum and rs_file
    end
    if not filepath then
      filepath, lnum, col = find_literal_in_project(segment, http_method)
    end
  elseif kind == "concat_var" and rs_file then
    lnum, col = find_path_param_only_method(rs_file)
    filepath = lnum and rs_file
  elseif kind == "base" and rs_file then
    lnum, col = find_base_method(rs_file, http_method)
    filepath = lnum and rs_file
  end

  if not filepath then
    vim.notify("Endpoint correspondente não encontrado no backend", vim.log.levels.WARN)
    if rs_file then
      vim.cmd("edit " .. vim.fn.fnameescape(rs_file))
    end
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
  vim.api.nvim_win_set_cursor(0, { lnum, col - 1 })
  vim.cmd("normal! zvzz")
end

return M
