const process = require '@std/process'

const API_KEY = process.env.ROBLOX_OPEN_CLOUD_API_KEY or ''
const UNIVERSE_ID = process.env.ROBLOX_TEST_UNIVERSE_ID or '10764356661'
const PLACE_ID = process.env.ROBLOX_TEST_PLACE_ID or '81854970452163'

const is_ci = process.env.CI == 'true'
const has_keys = #API_KEY > 0 and #UNIVERSE_ID > 1 and #PLACE_ID > 1

const function can_run_integration(assert: any): boolean
	if not has_keys and is_ci then
		print 'Skip (CI): Roblox integration skipped on external Pull Requests.'
		return false
	end

	assert.that(
		has_keys,
		'Local environment misconfigured. Set ROBLOX_OPEN_CLOUD_API_KEY, ROBLOX_TEST_UNIVERSE_ID, and ROBLOX_TEST_PLACE_ID to run integration tests locally.'
	)

	return true
end

return table.freeze {
	API_KEY = API_KEY,
	UNIVERSE_ID = UNIVERSE_ID,
	PLACE_ID = PLACE_ID,
	can_run_integration = can_run_integration,
}
