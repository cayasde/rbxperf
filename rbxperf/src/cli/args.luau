export type CliOptions = {
	paths: { string },
	api_key: string,
	universe_id: string,
	place_id: string,
	samples: number,
	warmup: number,
}

const env = require '@rbxperf/env'

export type Environment = env.Environment

export type ParseResult =
	{ kind: 'help' }
	| { kind: 'error', message: string }
	| { kind: 'options', options: CliOptions }

export type OptionHelp = {
	option: string,
	value_name: string?,
	description: string,
	default_value: string?,
}

type CountOption = {
	minimum: number,
	set: (options: CliOptions, value: number) -> (),
}

const ARGUMENT_START_INDEX = 2
const API_KEY_OPTION = '--api-key'
const UNIVERSE_ID_OPTION = '--universe-id'
const PLACE_ID_OPTION = '--place-id'
const SAMPLES_OPTION = '--samples'
const WARMUP_OPTION = '--warmup'
const HELP_SHORT_OPTION = '-h'
const HELP_LONG_OPTION = '--help'
const DEFAULT_SAMPLES = 1000
const DEFAULT_WARMUP = 100

const option_help: { OptionHelp } = {
	{
		option = API_KEY_OPTION,
		value_name = 'value',
		description = 'Roblox Open Cloud API key',
		default_value = nil,
	},
	{ option = UNIVERSE_ID_OPTION, value_name = 'id', description = 'Roblox universe ID', default_value = nil },
	{ option = PLACE_ID_OPTION, value_name = 'id', description = 'Roblox place ID', default_value = nil },
	{
		option = SAMPLES_OPTION,
		value_name = 'count',
		description = 'Number of measured samples',
		default_value = `{DEFAULT_SAMPLES}`,
	},
	{
		option = WARMUP_OPTION,
		value_name = 'count',
		description = 'Number of warmup calls',
		default_value = `{DEFAULT_WARMUP}`,
	},
	{
		option = `{HELP_SHORT_OPTION}, {HELP_LONG_OPTION}`,
		value_name = nil,
		description = 'Show this help message',
		default_value = nil,
	},
}

const function parse_count(name: string, value: string, minimum: number): (number?, string?)
	const parsed = tonumber(value)
	if not parsed or parsed < minimum or parsed % 1 ~= 0 then
		return nil, `Option {name} expects an integer greater than or equal to {minimum}, got '{value}'.`
	end

	return parsed, nil
end

const function next_value(args: { string }, index: number, option: string): (string?, number?, string?)
	const value = args[index + 1]
	if not value or value:sub(1, 1) == '-' then return nil, nil, `Option {option} expects a value.` end
	return value, index + 1, nil
end

const string_setters: { [string]: (CliOptions, string) -> () } = {
	[API_KEY_OPTION] = function(options: CliOptions, value: string)
		options.api_key = value
	end,
	[UNIVERSE_ID_OPTION] = function(options: CliOptions, value: string)
		options.universe_id = value
	end,
	[PLACE_ID_OPTION] = function(options: CliOptions, value: string)
		options.place_id = value
	end,
}

const count_options: { [string]: CountOption } = {
	[SAMPLES_OPTION] = {
		minimum = 1,
		set = function(options: CliOptions, value: number)
			options.samples = value
		end,
	},
	[WARMUP_OPTION] = {
		minimum = 0,
		set = function(options: CliOptions, value: number)
			options.warmup = value
		end,
	},
}

const function parse_option(options: CliOptions, args: { string }, index: number, option: string): (number?, string?)
	const string_setter = string_setters[option]
	if string_setter then
		const value, next_index, error_message = next_value(args, index, option)
		if not value or not next_index then return nil, error_message end
		string_setter(options, value)
		return next_index, nil
	end

	const count_option = count_options[option]
	if count_option then
		const value, next_index, error_message = next_value(args, index, option)
		if not value or not next_index then return nil, error_message end

		const count, count_error = parse_count(option, value, count_option.minimum)
		if not count then return nil, count_error end
		count_option.set(options, count)
		return next_index, nil
	end

	return nil, `Unknown option '{option}'. Use 'rbxperf --help'.`
end

const function parse(args: { string }, environment: Environment): ParseResult
	const options: CliOptions = {
		paths = {},
		api_key = environment.get_api_key() or '',
		universe_id = environment.get_universe_id() or '',
		place_id = environment.get_place_id() or '',
		samples = DEFAULT_SAMPLES,
		warmup = DEFAULT_WARMUP,
	}

	local index = ARGUMENT_START_INDEX
	while index <= #args do
		const option = args[index]

		if option == HELP_SHORT_OPTION or option == HELP_LONG_OPTION then return { kind = 'help' } end

		if option == '--' then
			for path_index = index + 1, #args do
				table.insert(options.paths, args[path_index])
			end
			break
		end

		if option:sub(1, 1) == '-' then
			const next_index, error_message = parse_option(options, args, index, option)
			if error_message then return { kind = 'error', message = error_message } end
			if not next_index then
				return { kind = 'error', message = `Failed to parse option '{option}'.` }
			end
			index = next_index
		else
			table.insert(options.paths, option)
		end

		index += 1
	end

	if #options.paths == 0 then
		return { kind = 'error', message = 'At least one benchmark path is required. Use \'rbxperf --help\'.' }
	end

	if options.api_key == '' then
		return {
			kind = 'error',
			message = `Missing API key. Set {env.keys.api_key} or pass {API_KEY_OPTION}.`,
		}
	end
	if options.universe_id == '' then
		return {
			kind = 'error',
			message = `Missing universe ID. Set {env.keys.universe_id} or pass {UNIVERSE_ID_OPTION}.`,
		}
	end
	if options.place_id == '' then
		return {
			kind = 'error',
			message = `Missing place ID. Set {env.keys.place_id} or pass {PLACE_ID_OPTION}.`,
		}
	end

	return { kind = 'options', options = options }
end

return table.freeze {
	DEFAULT_SAMPLES = DEFAULT_SAMPLES,
	DEFAULT_WARMUP = DEFAULT_WARMUP,
	option_help = table.freeze(option_help),
	parse = parse,
}
