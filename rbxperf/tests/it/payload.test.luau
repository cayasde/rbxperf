const test = require '@std/test'
const json = require '@std/json'
const ocale = require '@rbxperf/ocale'
const payload = require '@rbxperf/payload'
const config = require '@tests/config'

const ocale_config = { api_key = config.API_KEY, universe_id = config.UNIVERSE_ID, place_id = config.PLACE_ID }

test.suite('PayloadIntegrationSuite', function(suite)
	suite:case('should successfully run payload through Open Cloud and return valid statistics', function(assert)
		if not config.can_run_integration(assert) then return end

		const user_code = 'return function() local x = 0 for i = 1, 100 do x += math.sqrt(i) end end'
		const injected_script = payload.build(user_code, { warmup = 10, samples = 50 })
		const req = { script = injected_script }
		const response = ocale.execute_code(ocale_config, req)

		assert.eq('COMPLETE', response.state)
		assert.that(#response.results > 0, 'No results returned from engine')

		const stats = json.deserialize(response.results[1]) :: any

		assert.eq('number', type(stats.p0), 'p0 is missing or invalid')
		assert.eq('number', type(stats.p50), 'p50 is missing or invalid')
		assert.eq('number', type(stats.p90), 'p90 is missing or invalid')
		assert.eq('number', type(stats.p95), 'p95 is missing or invalid')
		assert.eq('number', type(stats.p100), 'p100 is missing or invalid')
		assert.eq('number', type(stats.mean), 'mean is missing or invalid')
		assert.eq(50, stats.samples_count, 'Sample count mismatch')
		assert.eq(10, stats.warmup_count, 'Warmup count mismatch')

		assert.that(stats.p0 > 0, 'Timing failure, p0 was 0')
	end)
end)
