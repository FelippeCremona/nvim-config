-- Config antiga do Oracle nunca funcionou de verdade (nada no config lia
-- essas variáveis, e o sqlplus que o dadbod usaria nem está instalado):
-- vim.g.db = 'jdbc:oracle:thin:@172.16.140.243:1521/orad01ng'
-- vim.g.db_user = 'pwscvrbd01'
-- vim.g.db_password = 'SCVRBD01'
-- vim.g.db_driver_classpath = '/home/cremona/trabalho/programas/jar/ojdbc6.jar'

-- DB2 (CSD1) via adaptador custom em autoload/db/adapter/db2.vim, usando o
-- sqlline (CLI JDBC genérica) + o driver JDBC do DB2. ":DB" sem argumento
-- usa essa conexão por padrão; o vim-dadbod-ui (:DBUI) também lê g:db
-- sozinho pra listar na interface, então não precisa duplicar em g:dbs.
--
-- Importante: o driver do JBoss (4.19.26, de 2014) é "down-level" demais
-- pro DB2 z/OS V12 e dá SQLCODE=-30025 (DSNL076I, incompatibilidade de
-- APPLCOMPAT — https://www.ibm.com/support/pages/apar/PH15092). Por isso
-- baixei uma versão atual (12.1.5.0, via Maven Central) em vez de apontar
-- pro jar do JBoss.
vim.g.db = 'db2://SNAFBD01:sna2006@10.192.224.76:5021/CSD1'
vim.g.db2_driver_jar = vim.fn.stdpath('data') .. '/db2/db2jcc4.jar'

require("cremona.core")
require("cremona.lazy")
