const fs = require '@std/fs'
const logger = require '@rbxperf/logger'

const function find_benchmarks(root_dir: string): { string }
	local results: { string } = {}

	local ok, entries = pcall(function()
		return fs.listDirectory(root_dir)
	end)

	if not ok then
		logger.warn(`Failed to scan directory '{root_dir}': {entries}`)
		return results
	end

	for _, entry in entries do
		const full_path = `{root_dir}/{entry.name}`

		if entry.type == 'dir' then
			const sub_results = find_benchmarks(full_path)
			for _, sub_path in sub_results do
				table.insert(results, sub_path)
			end
			continue
		end

		if entry.type == 'file' and entry.name:match '%.bench%.luau$' then table.insert(results, full_path) end
	end

	return results
end

return table.freeze { find_benchmarks = find_benchmarks }
