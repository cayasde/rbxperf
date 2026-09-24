const fs = require '@std/fs'
const json = require '@std/json'
const scanner = require '@rbxperf/scanner'
const payload = require '@rbxperf/payload'
const ocale = require '@rbxperf/ocale'
const logger = require '@rbxperf/logger'
const task = require '@std/task'

export type BenchmarkResult = {
	path: string,
	mean: number,
	p0: number,
	p50: number,
	p90: number,
	p95: number,
	p100: number,
	samples_count: number,
	warmup_count: number,
}

export type RunResult = {
	success: boolean,
	duration_seconds: number,
	results: { BenchmarkResult },
}

export type RunnerOptions = {
	paths: { string },
	api_key: string,
	universe_id: string,
	place_id: string,
	samples: number?,
	warmup: number?,
}

const function run(opts: RunnerOptions): RunResult
	const started_at = os.clock()
	const files: { string } = {}
	const seen_files: { [string]: boolean } = {}

	for _, path in opts.paths do
		for _, file_path in scanner.find_benchmarks(path) do
			if seen_files[file_path] then continue end
			seen_files[file_path] = true
			table.insert(files, file_path)
		end
	end

	if #files == 0 then
		logger.warn(`No .bench.luau files found in '{table.concat(opts.paths, ', ')}'`)
		return { success = true, duration_seconds = os.clock() - started_at, results = {} }
	end

	logger.info(`Found {#files} benchmark files. Dispatching concurrently to Roblox Cloud...`)

	const config: ocale.OcaleConfig =
		{ api_key = opts.api_key, universe_id = opts.universe_id, place_id = opts.place_id }

	local success = true
	local completed = 0
	const total_files = #files
	const results_by_path: { [string]: BenchmarkResult } = {}

	const hourly_pauses = math.floor((total_files - 1) / ocale.REQUESTS_PER_HOUR)
	const minute_pauses = math.floor((total_files - 1) / ocale.REQUESTS_PER_MINUTE) - hourly_pauses
	const estimated_minutes = (hourly_pauses * 60) + minute_pauses

	if estimated_minutes > 0 then
		logger.warn(`ETA: Execution will take ~{estimated_minutes} minutes due to Open Cloud quotas.`)
	end

	const function dispatch(file_path: string)
		logger.info(`Dispatching {file_path}...`)

		local read_ok, code = pcall(function()
			return fs.readFileToString(file_path)
		end)

		if not read_ok then
			logger.err(`Failed to read file {file_path}: {code}`)
			success = false
			return
		end

		const script = payload.build(code :: string, { samples = opts.samples, warmup = opts.warmup })

		local exec_ok, response = pcall(function()
			return ocale.execute_code(config, { script = script })
		end)

		if not exec_ok then
			logger.err(`Network/Execution failed for {file_path}: {response}`)
			success = false
			return
		end

		const res = response :: ocale.ExecuteLuauResponse

		if res.state ~= 'COMPLETE' then
			logger.err(
				`Engine state for {file_path} was {res.state}. Check your benchmark code for Yielding or Errors.`
			)
			success = false
			return
		end

		if #res.results == 0 then
			logger.err(`{file_path} returned no output. Did the script crash inside the engine?`)
			success = false
			return
		end

		local parse_ok, stats = pcall(function()
			return json.deserialize(res.results[1]) :: any
		end)

		if not parse_ok then
			logger.err(`Failed to parse JSON response from {file_path}: {stats}`)
			success = false
			return
		end

		results_by_path[file_path] = {
			path = file_path,
			mean = stats.mean,
			p0 = stats.p0,
			p50 = stats.p50,
			p90 = stats.p90,
			p95 = stats.p95,
			p100 = stats.p100,
			samples_count = stats.samples_count,
			warmup_count = stats.warmup_count,
		}
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
			const ok, error_message = pcall(function()
				dispatch(file_path)
			end)
			if not ok then
				logger.err(`Unexpected failure while processing {file_path}: {error_message}`)
				success = false
			end
			completed += 1
		end)
	end

	while completed < total_files do
		task.wait(0.1)
	end

	if not success then return { success = false, duration_seconds = os.clock() - started_at, results = {} } end

	const results: { BenchmarkResult } = {}
	for _, file_path in files do
		table.insert(results, results_by_path[file_path])
	end

	return { success = true, duration_seconds = os.clock() - started_at, results = results }
end

return table.freeze { run = run }
