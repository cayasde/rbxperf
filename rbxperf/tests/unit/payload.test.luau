const payload = require '@rbxperf/payload'
const test = require '@std/test'

test.suite('PayloadUnitSuite', function(suite)
	suite:case('should build valid string with default parameters', function(assert)
		const user_code = 'return function() print("hello") end'
		const result = payload.build(user_code)

		assert.that(result:match('return function%(%) print%("hello"%) end'), 'User code was not injected')
		assert.that(result:match('or 100\n'), 'Warmup default fallback missing')
		assert.that(result:match('or 1000\n'), 'Sampling default fallback missing')
	end)

	suite:case('should respect custom options', function(assert)
		const user_code = 'return function() end'
		const result = payload.build(user_code, { warmup = 50, samples = 200 })

		assert.that(result:match('or 50\n'), 'Custom warmup fallback failed')
		assert.that(result:match('or 200\n'), 'Custom sampling fallback failed')
	end)
end)
