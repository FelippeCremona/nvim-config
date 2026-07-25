" Location: autoload/db/adapter/db2.vim
"
" O vim-dadbod não tem adaptador nativo pro DB2. Esse aqui usa o driver JDBC
" (db2jcc4.jar, o mesmo usado pelo JBoss) via sqlline (CLI genérica de JDBC,
" um único jar, sem precisar instalar o cliente CLI do DB2).
"
" URL: db2://usuario:senha@host:porta/banco
"
" g:db2_java_bin      caminho do binário java (padrão: 'java' do PATH)
" g:db2_sqlline_jar   caminho do sqlline.jar (padrão: ~/.local/share/nvim/db2/sqlline.jar)
" g:db2_driver_jar     caminho do db2jcc4.jar (obrigatório configurar)

function! db#adapter#db2#canonicalize(url) abort
  return substitute(a:url, '^[^:]*:/\=/\@!', 'db2:///', '')
endfunction

function! s:jdbc_url(url) abort
  let url = db#url#parse(a:url)
  let host = get(url, 'host', 'localhost')
  let port = get(url, 'port', '50000')
  let path = get(url, 'path', '')
  return 'jdbc:db2://' . host . ':' . port . path
endfunction

function! s:classpath() abort
  let sqlline_jar = get(g:, 'db2_sqlline_jar', expand('~/.local/share/nvim/db2/sqlline.jar'))
  let driver_jar = get(g:, 'db2_driver_jar', '')
  if empty(driver_jar)
    throw 'DB: defina g:db2_driver_jar (caminho do db2jcc4.jar) pra usar o adaptador db2'
  endif
  return sqlline_jar . ':' . driver_jar
endfunction

function! db#adapter#db2#interactive(url) abort
  let url = db#url#parse(a:url)
  let cmd = [
        \ get(g:, 'db2_java_bin', 'java'),
        \ '-cp', s:classpath(),
        \ 'sqlline.SqlLine',
        \ '-d', 'com.ibm.db2.jcc.DB2Driver',
        \ '-u', s:jdbc_url(a:url),
        \ ]
  if has_key(url, 'user')
    let cmd += ['-n', url.user]
  endif
  if has_key(url, 'password')
    let cmd += ['-p', url.password]
  endif
  return cmd
endfunction

function! db#adapter#db2#filter(url) abort
  " O vim-dadbod já mescla stdout+stderr sozinho (job com on_stdout e
  " on_stderr escrevendo na mesma lista) — não precisa de "sh -c ... 2>&1"
  " aqui; isso só atrapalhava o envio da query via stdin usado pelo
  " vim-dadbod-ui (schemas/tabelas).
  "
  " outputformat=table: resultado como tabela ASCII (cabeçalho + bordas),
  " bem mais fácil de identificar coluna do que CSV com aspas. --maxWidth é
  " obrigatório aqui porque o job roda sem terminal real ("dumb terminal"),
  " e sem isso o sqlline detecta largura 0 e a tabela sai toda colapsada.
  return db#adapter#db2#interactive(a:url)
        \ + ['--silent=true', '--color=false', '--showHeader=true',
        \    '--outputformat=table', '--maxWidth=500']
endfunction

" Usado só pelo autoload/db_ui/schemas.vim (listagem de schemas/tabelas no
" :DBUI) — precisa de saída em CSV pra dar pra fazer parse, diferente do
" db#adapter#db2#filter() acima, que agora é só pra resultado visível.
function! db#adapter#db2#introspect(url) abort
  return db#adapter#db2#interactive(a:url)
        \ + ['--silent=true', '--color=false', '--showHeader=true', '--outputformat=csv']
endfunction

function! db#adapter#db2#auth_pattern() abort
  return 'SQLCODE=-4214\|Connection authorization failure'
endfunction

" Sem ";" no final, o sqlline fica esperando mais entrada e nunca roda a
" query quando ela vem via stdin (uso do :%DB, ao contrário do -e direto).
function! db#adapter#db2#massage(input) abort
  if a:input =~# ";\s*\n*$"
    return a:input
  endif
  return a:input . "\n;"
endfunction
