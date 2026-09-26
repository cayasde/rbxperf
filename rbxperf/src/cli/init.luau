const args = require '@cli/args'
const env = require '@cli/env'
const help = require '@cli/help'
const report = require '@cli/report'

return table.freeze {
	args = args,
	env = env,
	help = help,
	report = report,
}
