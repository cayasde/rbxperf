const fs = require '@std/fs'
const process = require '@std/process'

type Values = { [string]: string }

export type Environment = {
	read get_api_key: () -> string?,
	read get_universe_id: () -> string?,
	read get_place_id: () -> string?,
}

const KEYS = table.freeze {
	api_key = 'ROBLOX_OPEN_CLOUD_API_KEY',
	universe_id = 'ROBLOX_UNIVERSE_ID',
	place_id = 'ROBLOX_PLACE_ID',
}

const function trim(value: string): string
	return value:match '^%s*(.-)%s*$' or ''
end

const function parse(contents: string): Values
	const values: Values = {}

	for line in contents:gmatch '[^\r\n]+' do
		local entry = trim(line)

		if entry == '' or entry:sub(1, 1) == '#' then continue end
		entry = entry:gsub('^export%s+', '')

		const key, raw_value = entry:match '^([A-Za-z_][A-Za-z0-9_]*)%s*=%s*(.*)$'
		if not key or not raw_value then continue end
		local value = trim(raw_value)
		const quote = value:sub(1, 1)

		if (quote == '"' or quote == '\'') and value:sub(-1) == quote then value = value:sub(2, -2) end
		values[key] = value
	end

	return values
end

const function load(path: string): Environment
	const ok, contents = pcall(function()
		return fs.readFileToString(path)
	end)

	const dotenv_values: Values = if ok then parse(contents :: string) else {}

	const function get_value(key: string): string?
		return dotenv_values[key] or process.env[key]
	end

	const function get_api_key(): string?
		return get_value(KEYS.api_key)
	end

	const function get_universe_id(): string?
		return get_value(KEYS.universe_id)
	end

	const function get_place_id(): string?
		return get_value(KEYS.place_id)
	end

	return table.freeze {
		get_api_key = get_api_key,
		get_universe_id = get_universe_id,
		get_place_id = get_place_id,
	}
end

return table.freeze { keys = KEYS, load = load }
