const net = require '@std/net'
const json = require '@std/json'
const task = require '@std/task'

const MAX_CONCURRENT_TASKS = 10
const REQUESTS_PER_MINUTE = 5
const MAX_EXECUTION_TIME_SECONDS = 300

export type OcaleConfig = {
	api_key: string,
	universe_id: string,
	place_id: string,
}

export type ExecuteLuauRequest = { script: string }

export type LogMessage = {
	message: string,
	log_level: 'INFO' | 'WARNING' | 'ERROR',
}

export type ExecuteLuauResponse = {
	state: 'SUCCESS' | 'FAILED' | 'PENDING',
	results: { string },
}

type OpenCloudTaskResponse = {
	path: string?,
	state: string,
	output: { results: { string }? }?,
}

const function parse_response(poll_data: OpenCloudTaskResponse): ExecuteLuauResponse
	return { state = poll_data.state :: any, results = (poll_data.output and poll_data.output.results) or {} }
end

const function get_url(config: OcaleConfig): string
	return `https://apis.roblox.com/cloud/v2/universes/{config.universe_id}/places/{config.place_id}/luau-execution-session-tasks`
end

const function execute_code(config: OcaleConfig, req: ExecuteLuauRequest): ExecuteLuauResponse
	const create_res = net.request(get_url(config), {
		method = 'POST',
		headers = { ['x-api-key'] = config.api_key, ['Content-Type'] = 'application/json' },
		body = json.serialize(req :: any),
	})

	if not create_res.ok then
		error(`Failed to communicate with OCALE. Status: {create_res.status} | Error: {create_res.body}`)
	end

	const initial_data = (json.deserialize(create_res.body) :: unknown) :: OpenCloudTaskResponse
	const poll_url = `https://apis.roblox.com/cloud/v2/{initial_data.path}`

	for i = 1, 60 do
		task.wait(1)

		const poll_res = net.request(poll_url, { method = 'GET', headers = { ['x-api-key'] = config.api_key } })

		if not poll_res.ok then
			error(`Failed to poll OCALE task. Status: {poll_res.status} | Error: {poll_res.body}`)
		end

		const poll_data = (json.deserialize(poll_res.body) :: unknown) :: OpenCloudTaskResponse
		if poll_data.state ~= 'COMPLETE' and poll_data.state ~= 'FAILED' then continue end
		return parse_response(poll_data)
	end

	error 'OCALE task timed out after 60 seconds.'
end

return table.freeze {
	MAX_CONCURRENT_TASKS = MAX_CONCURRENT_TASKS,
	REQUESTS_PER_MINUTE = REQUESTS_PER_MINUTE,
	MAX_EXECUTION_TIME_SECONDS = MAX_EXECUTION_TIME_SECONDS,

	execute_code = execute_code,
}
