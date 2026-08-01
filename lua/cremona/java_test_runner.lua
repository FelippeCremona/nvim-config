-- lua/cremona/java_test_runner.lua

local M = {}

-- JDK usado para rodar o mvn test. Expandido pelo shell da janela tmux.
M.JAVA_HOME = "$HOME/trabalho/programas/java/jdk1.8.0_351"

-- Flags extras pra agilizar o mvn: -o evita checar atualização de
-- dependências no repositório remoto (exige que já estejam no repo local);
-- -T 1C builda os módulos do reactor em paralelo (uma thread por core).
-- Se algum dia faltar dependência nova, remova o -o temporariamente.
M.MVN_EXTRA_ARGS = "-o -T 1C"

-- Usado só no ,tt (projeto inteiro). Sem -T: com build paralelo o Maven
-- armazena a saída de cada módulo em buffer e só imprime tudo de uma vez
-- quando o módulo termina, o que quebraria o streaming de resultado por
-- classe conforme cada teste vai terminando.
M.MVN_PROJECT_ARGS = "-o"

-- Porta do agente JDWP usado pelo ,tD (debug de método de teste). Diferente
-- da porta 5005 do "Attach ao JBoss" (ftplugin/java.lua) pra não colidir
-- caso o JBoss esteja rodando ao mesmo tempo.
M.TEST_DEBUG_PORT = 5006

local function find_named_ancestor(node_type)
    local node = vim.treesitter.get_node()

    while node do
        if node:type() == node_type then
            local name_node = node:field("name")[1]
            if name_node then
                return vim.treesitter.get_node_text(name_node, 0)
            end
        end

        node = node:parent()
    end

    return nil
end

function M.current_method()
    return find_named_ancestor("method_declaration")
end

function M.current_class()
    return find_named_ancestor("class_declaration")
end

-- Convenção desse projeto: classe de teste termina em "Test"/"Tests" (ex:
-- RN052Test). Sem essa checagem, rodar ,tm/,tD/,tc com o cursor na classe de
-- produção (ex: RN052.java) monta um -Dtest=RN052 que não bate com nenhuma
-- classe, e o Surefire (2.12.3, nesse projeto) às vezes só ignora
-- silenciosamente em vez de avisar "No tests to run".
local function looks_like_test_class(class)
    return class:match("Tests?$") ~= nil
end

local function warn_if_not_test_class(class)
    if looks_like_test_class(class) then
        return true
    end
    vim.notify(
        string.format(
            '"%s" não parece uma classe de teste (sem sufixo "Test"/"Tests") — o cursor está no arquivo certo?',
            class
        ),
        vim.log.levels.WARN
    )
    return false
end

-- Nome do pacote do arquivo atual (a partir do "package ...;" do topo do
-- arquivo), usado pra montar o nome totalmente qualificado da classe e achar
-- o relatório do surefire (target/surefire-reports/TEST-<fqcn>.xml).
local function current_package()
    local node = vim.treesitter.get_node()

    while node and node:type() ~= "program" do
        node = node:parent()
    end

    if not node then
        return nil
    end

    for i = 0, node:child_count() - 1 do
        local child = node:child(i)
        if child:type() == "package_declaration" then
            for j = 0, child:child_count() - 1 do
                local sub = child:child(j)
                if sub:type() == "scoped_identifier" or sub:type() == "identifier" then
                    return vim.treesitter.get_node_text(sub, 0)
                end
            end
        end
    end

    return nil
end

-- Retorna o pom.xml do módulo mais próximo (module_dir) e o pom.xml mais
-- externo (root_dir), até o limite da raiz do repositório git. Rodar o mvn
-- direto do pom.xml do módulo falha em projetos multi-módulo, pois ele não
-- consegue resolver dependências/propriedades que só existem no reactor.
function M.find_maven_dirs(start_dir)
    local module_dir, root_dir
    local dir = start_dir

    while dir and dir ~= "" do
        if vim.fn.filereadable(dir .. "/pom.xml") == 1 then
            module_dir = module_dir or dir
            root_dir = dir
        end

        if vim.fn.isdirectory(dir .. "/.git") == 1 then
            break
        end

        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break
        end
        dir = parent
    end

    return module_dir, root_dir
end

-- test_filter == nil roda o projeto inteiro (sem -Dtest, sem -pl/-am).
-- test_filter pode conter variáveis de shell (ex: "${class}#${method}"),
-- já que em alguns casos é montado antes de o valor real existir.
local function build_mvn_cmd(root_dir, module_dir, test_filter, extra_args)
    local java_home_export = string.format('JAVA_HOME="%s"', M.JAVA_HOME)

    if not test_filter then
        return string.format("%s mvn %s test", java_home_export, extra_args)
    end

    if module_dir == root_dir then
        return string.format(
            "%s mvn %s -Dtest=%s -DfailIfNoTests=false test",
            java_home_export,
            extra_args,
            test_filter
        )
    end

    local module_rel = module_dir:sub(#root_dir + 2)
    return string.format(
        "%s mvn %s -pl %s -am -Dtest=%s -DfailIfNoTests=false test",
        java_home_export,
        extra_args,
        vim.fn.shellescape(module_rel),
        test_filter
    )
end

local function open_tmux_split(report_cmd)
    vim.fn.jobstart(
        {
            "tmux", "split-window", "-h", "-l", "30%", report_cmd,
            ";", "set-window-option", "remain-on-exit", "on",
        },
        { detach = true }
    )
end

function M.run_current_method_test()
    if vim.env.TMUX == nil then
        vim.notify("Não está dentro de uma sessão tmux", vim.log.levels.ERROR)
        return
    end

    local method = M.current_method()
    local class = M.current_class()

    if not method or not class then
        vim.notify("Método ou classe não encontrados", vim.log.levels.ERROR)
        return
    end

    if not warn_if_not_test_class(class) then
        return
    end

    local module_dir, root_dir = M.find_maven_dirs(vim.fn.expand("%:p:h"))
    if not module_dir then
        vim.notify("pom.xml não encontrado a partir do arquivo atual", vim.log.levels.ERROR)
        return
    end

    local mvn_cmd = build_mvn_cmd(
        root_dir,
        module_dir,
        string.format("%s#%s", class, method),
        M.MVN_EXTRA_ARGS
    )
    local log_file = vim.fn.tempname() .. ".log"

    local report_cmd = string.format(
        [[
title="%s"
subtitle="%s"
clear
echo "$title"
cols=$(tput cols 2>/dev/null || echo 80)
max_len=$((cols - 6))
if [ ${#subtitle} -gt $max_len ]; then
  display_subtitle="${subtitle:0:$((max_len - 1))}…"
else
  display_subtitle="$subtitle"
fi
( cd %s && %s ) > %s 2>&1 &
mvn_pid=$!
icon1="⏳"
icon2="⌛"
toggle=0
while kill -0 $mvn_pid 2>/dev/null; do
  if [ $toggle -eq 0 ]; then icon="$icon1"; toggle=1; else icon="$icon2"; toggle=0; fi
  printf '\r\033[K %%s %%s' "$icon" "$display_subtitle"
  sleep 0.4
done
wait $mvn_pid
mvn_status=$?
if [ $mvn_status -eq 0 ]; then
  color="\033[32m"; label="OK"
else
  color="\033[31m"; label="FAIL"
fi
printf '\r\033[K'
echo -e " ${color}[${label}]\033[0m $subtitle"
echo
echo "log: %s"
exec "${SHELL:-/bin/bash}"
]],
        class,
        method,
        vim.fn.shellescape(root_dir),
        mvn_cmd,
        vim.fn.shellescape(log_file),
        log_file
    )

    open_tmux_split(report_cmd)
end

-- Roda o método atual com o surefire em modo debug: a JVM do teste sobe e
-- FICA PARADA (suspend=y) esperando um debugger conectar na porta
-- TEST_DEBUG_PORT antes de executar qualquer coisa. Coloque o breakpoint
-- antes de chamar isso; quando aparecer "Listening for transport" no split,
-- dê <F8> no nvim e escolha "Debug teste (porta 5006)".
function M.run_current_method_debug()
    if vim.env.TMUX == nil then
        vim.notify("Não está dentro de uma sessão tmux", vim.log.levels.ERROR)
        return
    end

    local method = M.current_method()
    local class = M.current_class()

    if not method or not class then
        vim.notify("Método ou classe não encontrados", vim.log.levels.ERROR)
        return
    end

    if not warn_if_not_test_class(class) then
        return
    end

    local module_dir, root_dir = M.find_maven_dirs(vim.fn.expand("%:p:h"))
    if not module_dir then
        vim.notify("pom.xml não encontrado a partir do arquivo atual", vim.log.levels.ERROR)
        return
    end

    local debug_arg = string.format(
        '-Dmaven.surefire.debug="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=%d"',
        M.TEST_DEBUG_PORT
    )
    local mvn_cmd = build_mvn_cmd(
        root_dir,
        module_dir,
        string.format("%s#%s", class, method),
        M.MVN_EXTRA_ARGS .. " " .. debug_arg
    )

    -- Aqui não tem spinner nem log escondido: precisamos ver a saída crua
    -- do mvn pra confirmar quando o "Listening for transport" aparecer.
    local report_cmd = string.format(
        [[
clear
echo "%s#%s (debug, porta %d)"
echo "Aguardando \"Listening for transport\" abaixo, depois <F8> no nvim -> 'Debug teste (porta %d)'"
echo
cd %s && %s
echo
exec "${SHELL:-/bin/bash}"
]],
        class,
        method,
        M.TEST_DEBUG_PORT,
        M.TEST_DEBUG_PORT,
        vim.fn.shellescape(root_dir),
        mvn_cmd
    )

    open_tmux_split(report_cmd)
end

function M.run_current_class_test()
    if vim.env.TMUX == nil then
        vim.notify("Não está dentro de uma sessão tmux", vim.log.levels.ERROR)
        return
    end

    local class = M.current_class()
    if not class then
        vim.notify("Classe não encontrada", vim.log.levels.ERROR)
        return
    end

    if not warn_if_not_test_class(class) then
        return
    end

    local package_name = current_package()
    local fqcn = package_name and string.format("%s.%s", package_name, class) or class

    local module_dir, root_dir = M.find_maven_dirs(vim.fn.expand("%:p:h"))
    if not module_dir then
        vim.notify("pom.xml não encontrado a partir do arquivo atual", vim.log.levels.ERROR)
        return
    end

    local mvn_cmd = build_mvn_cmd(root_dir, module_dir, class, M.MVN_EXTRA_ARGS)
    local log_file = vim.fn.tempname() .. ".log"
    local report_xml = string.format("%s/target/surefire-reports/TEST-%s.xml", module_dir, fqcn)

    -- Roda a classe inteira numa chamada só (rápido, sem os problemas de rodar
    -- método a método). Ao terminar, lê o relatório XML do surefire (que tem
    -- cada testcase individualmente) pra detalhar o resultado por método.
    local report_cmd = string.format(
        [[
class="%s"
report_xml=%s
clear
echo "$class"
cols=$(tput cols 2>/dev/null || echo 80)
max_len=$((cols - 6))
subtitle="rodando testes..."
if [ ${#subtitle} -gt $max_len ]; then
  display_subtitle="${subtitle:0:$((max_len - 1))}…"
else
  display_subtitle="$subtitle"
fi
( cd %s && %s ) > %s 2>&1 &
mvn_pid=$!
icon1="⏳"
icon2="⌛"
toggle=0
while kill -0 $mvn_pid 2>/dev/null; do
  if [ $toggle -eq 0 ]; then icon="$icon1"; toggle=1; else icon="$icon2"; toggle=0; fi
  printf '\r\033[K %%s %%s' "$icon" "$display_subtitle"
  sleep 0.4
done
wait $mvn_pid
mvn_status=$?
printf '\r\033[K'
if [ -f "$report_xml" ] && command -v python3 >/dev/null 2>&1; then
  python3 - "$report_xml" << 'PYEOF'
import sys
import xml.etree.ElementTree as ET

tree = ET.parse(sys.argv[1])
root = tree.getroot()
for tc in root.findall("testcase"):
    name = tc.get("name")
    failed = tc.find("failure") is not None or tc.find("error") is not None
    if failed:
        print(f" \033[31m[FAIL]\033[0m {name}")
    else:
        print(f" \033[32m[OK]\033[0m {name}")
PYEOF
else
  if [ $mvn_status -eq 0 ]; then
    echo -e " \033[32m[OK]\033[0m $class"
  else
    echo -e " \033[31m[FAIL]\033[0m $class"
  fi
fi
echo
if [ $mvn_status -eq 0 ]; then
  echo -e " \033[1;32mBUILD OK\033[0m"
else
  echo -e " \033[1;31mBUILD FAIL\033[0m"
fi
echo "log: %s"
exec "${SHELL:-/bin/bash}"
]],
        class,
        vim.fn.shellescape(report_xml),
        vim.fn.shellescape(root_dir),
        mvn_cmd,
        vim.fn.shellescape(log_file),
        log_file
    )

    open_tmux_split(report_cmd)
end

function M.run_project_test()
    if vim.env.TMUX == nil then
        vim.notify("Não está dentro de uma sessão tmux", vim.log.levels.ERROR)
        return
    end

    local _, root_dir = M.find_maven_dirs(vim.fn.expand("%:p:h"))
    if not root_dir then
        vim.notify("pom.xml não encontrado a partir do arquivo atual", vim.log.levels.ERROR)
        return
    end

    local mvn_cmd = build_mvn_cmd(root_dir, root_dir, nil, M.MVN_PROJECT_ARGS)
    local log_file = vim.fn.tempname() .. ".log"
    local status_file = vim.fn.tempname()

    -- Sem -T (reactor sequencial), o surefire imprime "Running Classe" e,
    -- em seguida, "Tests run: ..." assim que cada classe termina — por
    -- isso dá pra mostrar o resultado ao vivo, classe por classe.
    local report_cmd = string.format(
        [[
clear
echo "Projeto completo"
printf ' ⏳ compilando/rodando testes...'
{ ( cd %s && %s ); echo $? > %s; } 2>&1 | while IFS= read -r line; do
  printf '%%s\n' "$line" >> %s
  case "$line" in
    "Running "*)
      current_class="${line#Running }"
      ;;
    "Tests run:"*)
      case "$line" in
        *"- in "*) cls="${line##*- in }" ;;
        *) cls="$current_class" ;;
      esac
      case "$line" in
        *"Failures: 0, Errors: 0"*) color="\033[32m"; label="OK" ;;
        *) color="\033[31m"; label="FAIL" ;;
      esac
      printf '\r\033[K'
      echo -e " ${color}[${label}]\033[0m ${cls}"
      ;;
  esac
done
mvn_status=$(cat %s)
echo
if [ "$mvn_status" = "0" ]; then
  echo -e " \033[1;32mBUILD OK\033[0m"
else
  echo -e " \033[1;31mBUILD FAIL\033[0m"
fi
echo "log: %s"
exec "${SHELL:-/bin/bash}"
]],
        vim.fn.shellescape(root_dir),
        mvn_cmd,
        vim.fn.shellescape(status_file),
        vim.fn.shellescape(log_file),
        vim.fn.shellescape(status_file),
        log_file
    )

    open_tmux_split(report_cmd)
end

function M.setup()
    vim.keymap.set(
        "n",
        ",tm",
        M.run_current_method_test,
        { buffer = true, desc = "Rodar teste do método atual em split tmux" }
    )

    vim.keymap.set(
        "n",
        ",tD",
        M.run_current_method_debug,
        { buffer = true, desc = "Rodar teste do método atual em modo debug (JVM pausada, porta 5006)" }
    )

    vim.keymap.set(
        "n",
        ",tc",
        M.run_current_class_test,
        { buffer = true, desc = "Rodar testes da classe atual (detalhado por método) em split tmux" }
    )

    vim.keymap.set(
        "n",
        ",tt",
        M.run_project_test,
        { buffer = true, desc = "Rodar todos os testes do projeto (por classe, ao vivo) em split tmux" }
    )
end

return M
