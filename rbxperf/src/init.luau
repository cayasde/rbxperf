const fs = require '@std/fs'
const json = require '@std/json'
const scanner = require '@rbxperf/scanner'
const payload = require '@rbxperf/payload'
const ocale = require '@rbxperf/ocale'
const logger = require '@rbxperf/logger'
const task = require '@std/task'

export type RunnerOptions = {
	dir: string,
	api_key: string,
	universe_id: string,
	place_id: string,
}

const function format_ms(val: number): string
	return string.format('%.3fms', val)
end

const function run(opts: RunnerOptions): boolean
	const files = scanner.find_benchmarks(opts.dir)

	if #files == 0 then
		logger.warn(`No .bench.luau files found in '{opts.dir}'`)
		return true
	end

	logger.info(`Found {#files} benchmark files. Dispatching concurrently to Roblox Cloud...`)

	const config: ocale.OcaleConfig =
		{ api_key = opts.api_key, universe_id = opts.universe_id, place_id = opts.place_id }

	local success = true
	local completed = 0
	const total_files = #files

	const hourly_pauses = math.floor((total_files - 1) / ocale.REQUESTS_PER_HOUR)
	const minute_pauses = math.floor((total_files - 1) / ocale.REQUESTS_PER_MINUTE) - hourly_pauses
	const estimated_minutes = (hourly_pauses * 60) + minute_pauses

	if estimated_minutes > 0 then
		logger.warn(`ETA: Execution will take ~{estimated_minutes} minutes due to Open Cloud quotas.`)
	end

	for i, file_path in files do
		const is_hourly_pause = i > 1 and (i - 1) % ocale.REQUESTS_PER_HOUR == 0
		const is_minute_pause = i > 1 and (i - 1) % ocale.REQUESTS_PER_MINUTE == 0 and not is_hourly_pause

		if is_hourly_pause then
			logger.warn(
				`Hourly quota reached ({ocale.REQUESTS_PER_HOUR} RPH). Sleeping for 1 hour to prevent API lockout...`
			)
			task.wait(3600)
		end

		if is_minute_pause then
			logger.warn(`Rate limit reached ({ocale.REQUESTS_PER_MINUTE} RPM). Sleeping for 60 seconds...`)
			task.wait(60)
		end

		task.spawn(function()
			logger.info(`Dispatching {file_path}...`)

			local read_ok, code = pcall(function()
				return fs.readFileToString(file_path)
			end)

			if not read_ok then
				logger.err(`Failed to read file {file_path}: {code}`)
				success = false
				completed += 1
				return
			end

			const script = payload.build(code :: string)

			local exec_ok, response = pcall(function()
				return ocale.execute_code(config, { script = script })
			end)

			if not exec_ok then
				logger.err(`Network/Execution failed for {file_path}: {response}`)
				success = false
				completed += 1
				return
			end

			const res = response :: ocale.ExecuteLuauResponse

			if res.state ~= 'COMPLETE' then
				logger.err(
					`Engine state for {file_path} was {res.state}. Check your benchmark code for Yielding or Errors.`
				)
				success = false
				completed += 1
				return
			end

			if #res.results == 0 then
				logger.err(`{file_path} returned no output. Did the script crash inside the engine?`)
				success = false
				completed += 1
				return
			end

			local parse_ok, stats = pcall(function()
				return json.deserialize(res.results[1]) :: any
			end)

			if not parse_ok then
				logger.err(`Failed to parse JSON response from {file_path}: {stats}`)
				success = false
				completed += 1
				return
			end

			logger.success(
				`[{file_path}] p50: {format_ms(stats.p50)} | p95: {format_ms(stats.p95)} | p99: {format_ms(
					stats.p99
				)} | mean: {format_ms(stats.mean)}`
			)

			completed += 1
		end)
	end

	while completed < total_files do
		task.wait(0.1)
	end

	return success
end

return table.freeze { run = run }
