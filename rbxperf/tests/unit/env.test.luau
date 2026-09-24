const env = require '@cli/env'
const test = require '@std/test'
const fs = require '@std/fs'
const process = require '@std/process'

test.suite('EnvUnitSuite', function(suite)
	suite:case('should parse dotenv syntax', function(assert)
		const values = env.parse [[
# ignored
export API_KEY = "quoted-value"
PLAIN=value
EMPTY=
invalid line
]]

		assert.eq('quoted-value', values.API_KEY)
		assert.eq('value', values.PLAIN)
		assert.eq('', values.EMPTY)
		assert.eq(nil, values.invalid)
	end)

	suite:case('should prefer dotenv values over OS values', function(assert)
		const path = 'tests/scratch_env_test.env'
		fs.writeStringToFile(path, 'PATH=dotenv-path\nRBXPERF_ENV_NUMBER=42\n')

		const loaded = env.load(path)
		fs.remove(path)

		assert.eq('dotenv-path', loaded.str 'PATH')
		assert.eq(42, loaded.number 'RBXPERF_ENV_NUMBER')
		assert.eq(process.env.PATH, env.load('missing_env_file.env').str 'PATH')
	end)
end)
