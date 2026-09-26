const env = require '@rbxperf/env'
const test = require '@std/test'
const fs = require '@std/fs'

test.suite('EnvUnitSuite', function(suite)
	suite:case('should load named program values from dotenv', function(assert)
		const path = 'tests/scratch_env_test.env'
		fs.writeStringToFile(path, [[
# ignored
export ROBLOX_OPEN_CLOUD_API_KEY = "dotenv-key"
ROBLOX_UNIVERSE_ID=dotenv-universe
ROBLOX_PLACE_ID=dotenv-place
invalid line
]])

		const loaded = env.load(path)
		fs.remove(path)

		assert.eq('dotenv-key', loaded.get_api_key())
		assert.eq('dotenv-universe', loaded.get_universe_id())
		assert.eq('dotenv-place', loaded.get_place_id())
	end)
end)
