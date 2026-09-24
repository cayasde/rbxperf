const template = require '@self/template'

export type PayloadOptions = { samples: number?, warmup: number? }
const function build(user_code: string, opts: PayloadOptions?): string
	const samples = (opts and opts.samples) or 1000
	const warmup = (opts and opts.warmup) or 100

	local final_string, _ = template:gsub('{{([A-Z_]+)}}', {
		USER_CODE = user_code,
		WARMUP = tostring(warmup),
		SAMPLES = tostring(samples),
	})

	return final_string
end

return table.freeze { build = build }
