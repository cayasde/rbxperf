const process = require '@std/process'
const runner = require '@rbxperf/runner'
const cli = require '@cli'
const logger = require '@rbxperf/logger'

const environment = cli.env.load '.env'
const result = cli.args.parse({ ... }, environment)

if result.kind == 'help' then
	cli.help.print_usage()
	process.exit(0)
	return
end

if result.kind == 'error' then
	logger.err(result.message)
	process.exit(2)
	return
end

if result.kind == 'options' then
	const options = result.options
	const runner_options: runner.RunnerOptions = {
		paths = options.paths,
		api_key = options.api_key,
		universe_id = options.universe_id,
		place_id = options.place_id,
		samples = options.samples,
		warmup = options.warmup,
	}

	const run_result = runner.run(runner_options)
	if not run_result.success then process.exit(1) end
	if #run_result.results == 0 then process.exit(0) end

	for _, line in cli.report.format(run_result.results, run_result.duration_seconds) do
		print(line)
	end

	process.exit(0)
end
