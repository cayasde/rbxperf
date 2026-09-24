export type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR'

local LEVELS = {
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
}

local COLORS = {
	DEBUG = '\27[36m', -- Cyan
	INFO = '\27[34m', -- Blue
	WARN = '\27[33m', -- Yellow
	ERROR = '\27[31m', -- Red
	SUCCESS = '\27[32m', -- Green
	RESET = '\27[0m',
}

local current_level: LogLevel = 'INFO'
local writer: (string) -> () = print

const function set_level(level: LogLevel)
	current_level = level
end

const function set_writer(custom_writer: (string) -> ())
	writer = custom_writer
end

const function log(level: LogLevel, message: string)
	if LEVELS[level] < LEVELS[current_level] then return end

	const color = COLORS[level] or COLORS.RESET
	writer(`{color}[{level}]{COLORS.RESET} {message}`)
end

const function debug(message: string)
	log('DEBUG', message)
end

const function info(message: string)
	log('INFO', message)
end

const function warn(message: string)
	log('WARN', message)
end

const function err(message: string)
	log('ERROR', message)
end

const function success(message: string)
	if LEVELS['INFO'] < LEVELS[current_level] then return end
	writer(`{COLORS.SUCCESS}[SUCCESS]{COLORS.RESET} {message}`)
end

return table.freeze {
	set_level = set_level,
	set_writer = set_writer,
	debug = debug,
	info = info,
	warn = warn,
	err = err,
	success = success,
}
