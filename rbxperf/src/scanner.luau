const fs = require '@std/fs'
const logger = require '@rbxperf/logger'

const function find_benchmarks(root_path: string): { string }
	local results: { string } = {}

	local type_ok, entry_type = pcall(function()
		return fs.type(root_path)
	end)

	if not type_ok then
		logger.warn(`Failed to inspect path '{root_path}': {entry_type}`)
		return results
	end

	if entry_type == 'file' and root_path:match '%.bench%.luau$' then return { root_path } end

	if entry_type == 'file' then
		logger.warn(`Ignoring non-benchmark file '{root_path}'`)
		return results
	end

	if entry_type ~= 'dir' then
		logger.warn(`Ignoring unsupported benchmark path '{root_path}' ({entry_type})`)
		return results
	end

	local ok, entries = pcall(function()
		return fs.listDirectory(root_path)
	end)

	if not ok then
		logger.warn(`Failed to scan directory '{root_path}': {entries}`)
		return results
	end

	for _, entry in entries do
		const full_path = `{root_path}/{entry.name}`

		if entry.type == 'file' and entry.name:match '%.bench%.luau$' then table.insert(results, full_path) end
		if entry.type ~= 'dir' then continue end

		const sub_results = find_benchmarks(full_path)
		for _, sub_path in sub_results do
			table.insert(results, sub_path)
		end
	end

	return results
end

return table.freeze { find_benchmarks = find_benchmarks }
