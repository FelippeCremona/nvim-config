local config = {
	cmd = {
			'java'
			'-Declipse.application=org.eclipse.jdt.ls.core.id1'
			'-Dosgi.bundles.defaultStartLevel=4'
			'-Declipse.product=org.eclipse.jdt.ls.core.product'
			'-Dlog.level=ALL'
			'-noverify'
			'-Xmx1G'
			'-jar', 'C://Trabalho//Programas//Java//jdt-language-server-1.9.0-202203031534//plugins//org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar'
			'-configuration', 'C://Trabalho//Programas//Java//jdt-language-server-1.9.0-202203031534//config_win//'
			'-data', vim.fn.expand('c://.cache//jdtls-workspace') .. workspace_dir
		  },
		  
	root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'})
	capabilities = capabilities
}
require('jdtls').start_or_attach(config)