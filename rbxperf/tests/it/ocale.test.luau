const ocale = require '@rbxperf/ocale'
const test = require '@std/test'
const config = require '@tests/config'

const ocale_config = { api_key = config.API_KEY, universe_id = config.UNIVERSE_ID, place_id = config.PLACE_ID }

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
		if not config.can_run_integration(assert) then return end

		const req = { script = 'return \'integration_test_ok\'' }
		const response = ocale.execute_code(ocale_config, req)

		assert.eq('COMPLETE', response.state)
		assert.that(#response.results > 0)
		assert.eq('integration_test_ok', response.results[1])
	end)
end)
