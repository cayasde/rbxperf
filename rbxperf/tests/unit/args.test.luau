const args = require '@cli/args'
const test = require '@std/test'

const function environment(values: { [string]: string }): args.Environment
	return {
		str = function(key: string)
			return values[key] or ''
		end,
	}
end

test.suite('ArgsUnitSuite', function(suite)
	suite:case('should parse paths and options', function(assert)
		const result = args.parse(
			{
				'cli/init.luau',
				'./benchmarks',
				'./other.bench.luau',
				'--api-key',
				'argument-key',
				'--universe-id',
				'123',
				'--place-id',
				'456',
				'--samples',
				'500',
				'--warmup',
				'0',
			},
			environment {
				['ROBLOX_OPEN_CLOUD_API_KEY'] = 'environment-key',
				['ROBLOX_UNIVERSE_ID'] = 'environment-universe',
				['ROBLOX_PLACE_ID'] = 'environment-place',
			}
		)

		assert.eq('options', result.kind)
		if result.kind ~= 'options' then return end

		assert.eq(2, #result.options.paths)
		assert.eq('./benchmarks', result.options.paths[1])
		assert.eq('./other.bench.luau', result.options.paths[2])
		assert.eq('argument-key', result.options.api_key)
		assert.eq('123', result.options.universe_id)
		assert.eq('456', result.options.place_id)
		assert.eq(500, result.options.samples)
		assert.eq(0, result.options.warmup)
	end)

	suite:case('should treat values after -- as paths', function(assert)
		const result = args.parse({
			'cli/init.luau',
			'--api-key',
			'key',
			'--universe-id',
			'123',
			'--place-id',
			'456',
			'--',
			'--benchmark.bench.luau',
			'-literal-path',
		}, environment {})

		assert.eq('options', result.kind)
		if result.kind ~= 'options' then return end

		assert.eq(2, #result.options.paths)
		assert.eq('--benchmark.bench.luau', result.options.paths[1])
		assert.eq('-literal-path', result.options.paths[2])
	end)

	suite:case('should return help before validating required options', function(assert)
		const result = args.parse({ 'cli/init.luau', '--help' }, environment {})
		assert.eq('help', result.kind)
	end)

	suite:case('should reject invalid options and counts', function(assert)
		const unknown = args.parse({ 'cli/init.luau', 'path', '--unknown' }, environment {})
		assert.eq('error', unknown.kind)
		if unknown.kind == 'error' then assert.that(unknown.message:match 'Unknown option') end

		const invalid_count = args.parse({ 'cli/init.luau', 'path', '--samples', '0' }, environment {})
		assert.eq('error', invalid_count.kind)
		if invalid_count.kind == 'error' then assert.that(invalid_count.message:match 'expects an integer') end
	end)

	suite:case('should apply environment values and defaults', function(assert)
		const result = args.parse(
			{ 'cli/init.luau', 'path' },
			environment {
				['ROBLOX_OPEN_CLOUD_API_KEY'] = 'environment-key',
				['ROBLOX_UNIVERSE_ID'] = 'environment-universe',
				['ROBLOX_PLACE_ID'] = 'environment-place',
			}
		)

		assert.eq('options', result.kind)
		if result.kind ~= 'options' then return end

		assert.eq('environment-key', result.options.api_key)
		assert.eq('environment-universe', result.options.universe_id)
		assert.eq('environment-place', result.options.place_id)
		assert.eq(args.DEFAULT_SAMPLES, result.options.samples)
		assert.eq(args.DEFAULT_WARMUP, result.options.warmup)
	end)
end)
