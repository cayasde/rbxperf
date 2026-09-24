const scanner = require '@rbxperf/scanner'
const test = require '@std/test'
const fs = require '@std/fs'
const logger = require '@rbxperf/logger'

test.suite('ScannerIntegrationSuite', function(suite)
	suite:case('should return empty table for invalid directory', function(assert)
		logger.set_writer(function() end)
		const results = scanner.find_benchmarks('this_directory_does_not_exist_at_all_123')
		logger.set_writer(print)

		assert.eq(0, #results)
	end)

	suite:case('should recursively find only .bench.luau files', function(assert)
		const scratch_dir = 'tests/scratch_scanner_test_dir'

		fs.createDirectory(scratch_dir, { makeParents = true })
		fs.writeStringToFile(`{scratch_dir}/a.bench.luau`, 'mock')
		fs.writeStringToFile(`{scratch_dir}/ignored.luau`, 'mock')
		fs.writeStringToFile(`{scratch_dir}/ignored.txt`, 'mock')

		fs.createDirectory(`{scratch_dir}/nested`)
		fs.writeStringToFile(`{scratch_dir}/nested/b.bench.luau`, 'mock')
		fs.writeStringToFile(`{scratch_dir}/nested/ignored2.luau`, 'mock')

		const results = scanner.find_benchmarks(scratch_dir)
		fs.removeDirectory(scratch_dir, { recursive = true })

		assert.eq(2, #results, 'Did not find exactly 2 benchmark files')

		local found_a = false
		local found_b = false

		for _, path in results do
			if path:match 'a%.bench%.luau$' then found_a = true end
			if path:match 'b%.bench%.luau$' then found_b = true end
			assert.that(path:match '%.bench%.luau$', 'Scanner picked up a non-benchmark file')
		end

		assert.that(found_a, 'Failed to find root benchmark file')
		assert.that(found_b, 'Failed to find nested benchmark file')
	end)
end)
