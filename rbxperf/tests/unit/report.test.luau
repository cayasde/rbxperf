const report = require '@cli/report'
const test = require '@std/test'

test.suite('ReportUnitSuite', function(suite)
	suite:case('should format benchmark tables and summary', function(assert)
		const lines = report.format({
			{
				path = 'src/math.bench.luau',
				mean = 2.1,
				p0 = 1.0,
				p50 = 2.0,
				p90 = 2.2,
				p95 = 2.3,
				p100 = 2.5,
				samples_count = 1000,
				warmup_count = 100,
			},
		}, 4.2)

		assert.eq('', lines[1])
		assert.eq('src/math.bench.luau', lines[2])
		assert.eq(
			'│ Metric (ms) │ Mean    │ Min     │ P50     │ P90     │ P95     │ Max     │',
			lines[4]
		)
		assert.eq(
			'│ Bench Time  │   2.100 │   1.000 │   2.000 │   2.200 │   2.300 │   2.500 │',
			lines[6]
		)
		assert.eq('✔ Success: 1 benchmarks completed in 4.2s.', lines[9])
		assert.eq('  Warmups: 100 | Samples: 1000', lines[10])
	end)

	suite:case('should return no output for empty results', function(assert)
		assert.eq(0, #report.format({}, 0))
	end)
end)
