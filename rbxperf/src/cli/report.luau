const runner = require '@rbxperf/runner'

type BenchmarkResult = runner.BenchmarkResult

const BORDER =
	'┌─────────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐'
const HEADER = '│ Metric (ms) │ Mean    │ Min     │ P50     │ P90     │ P95     │ Max     │'
const SEPARATOR =
	'├─────────────┼─────────┼─────────┼─────────┼─────────┼─────────┼─────────┤'
const BOTTOM =
	'└─────────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘'

const function format(results: { BenchmarkResult }, duration_seconds: number): { string }
	if #results == 0 then return {} end

	const lines: { string } = {}
	table.insert(lines, '')

	for _, result in results do
		table.insert(lines, result.path)
		table.insert(lines, BORDER)
		table.insert(lines, HEADER)
		table.insert(lines, SEPARATOR)
		table.insert(
			lines,
			string.format(
				'│ Bench Time  │ %7.3f │ %7.3f │ %7.3f │ %7.3f │ %7.3f │ %7.3f │',
				result.mean,
				result.p0,
				result.p50,
				result.p90,
				result.p95,
				result.p100
			)
		)
		table.insert(lines, BOTTOM)
		table.insert(lines, '')
	end

	table.insert(
		lines,
		`✔ Success: {#results} benchmarks completed in {string.format('%.1f', duration_seconds)}s.`
	)

	const samples_count = results[1].samples_count
	const warmup_count = results[1].warmup_count
	local consistent_counts = true

	for _, result in results do
		if result.samples_count ~= samples_count or result.warmup_count ~= warmup_count then
			consistent_counts = false
			break
		end
	end

	if not consistent_counts then
		table.insert(lines, '  Warmups/Samples: per-benchmark configuration')
		return lines
	end

	table.insert(lines, `  Warmups: {warmup_count} | Samples: {samples_count}`)
	return lines
end

return table.freeze { format = format }
