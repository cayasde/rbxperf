const ocale = require '@rbxperf/ocale'
const process = require '@std/process'
const test = require '@std/test'

const API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY or ''
const UNIVERSE_ID = process.env.ROBLOX_TEST_UNIVERSE_ID or '10764356661'
const PLACE_ID = process.env.ROBLOX_TEST_PLACE_ID or '81854970452163'

test.suite('OcaleIntegrationSuite', function(suite)
	suite:case('should fail gracefully with invalid credentials', function(assert)
		const bad_config = { api_key = 'INVALID_KEY_123', universe_id = '123456', place_id = '123456' }
		const req = { script = 'return \'hello\'' }

		const ok, err = pcall(function()
			ocale.execute_code(bad_config, req)
		end)

		assert.eq(false, ok)
		assert.that(tostring(err):match '40[134]', 'Error was not authentication or routing related')
	end)

	suite:case('should succeed with valid credentials', function(assert)
		const is_ci = process.env.CI == 'true'
		const has_keys = #API_KEY > 0 and #UNIVERSE_ID > 1 and #PLACE_ID > 1

		if not has_keys and is_ci then
			print 'Skip (CI): Roblox integration skipped on external Pull Requests.'
			return
		end

		assert.that(
			has_keys,
			'Local environment misconfigured. Set ROBLOX_OPEN_CLOUD_API_KEY, ROBLOX_TEST_UNIVERSE_ID, and ROBLOX_TEST_PLACE_ID to run integration tests locally.'
		)

		const config = { api_key = API_KEY, universe_id = UNIVERSE_ID, place_id = PLACE_ID }
		const req = { script = 'return \'integration_test_ok\'' }
		const response = ocale.execute_code(config, req)

		assert.eq('COMPLETE', response.state)
		assert.that(#response.results > 0)
		assert.eq('integration_test_ok', response.results[1])
	end)
end)
