const parser = require '@cli/args'
const env = require '@rbxperf/env'

const function print_usage()
	print [[
Usage:
  rbxperf <path>... [options]

Arguments:
  <path>...             Benchmark file or directory; directories are recursive

Options:]]

	for _, option in parser.option_help do
		const value_suffix = if option.value_name then ` <{option.value_name}>` else ''
		const default_suffix = if option.default_value then ` (default: {option.default_value})` else ''
		print(
			string.format(
				'  %-21s %s%s',
				`{option.option}{value_suffix}`,
				option.description,
				default_suffix
			)
		)
	end

	print ''
	print [[
Environment:
  Values are read from .env in the current directory and the OS environment.
  .env values override OS environment variables.
]]
	print(string.format('  %-29s %s', env.keys.api_key, 'API key'))
	print(string.format('  %-29s %s', env.keys.universe_id, 'Universe ID'))
	print(string.format('  %-29s %s', env.keys.place_id, 'Place ID'))
end

return table.freeze { print_usage = print_usage }
