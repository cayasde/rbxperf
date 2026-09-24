return [[
const HttpService = game:GetService("HttpService")

const user_module = (function()
{{USER_CODE}}
end)()

const is_function = type(user_module) == "function"
const is_table = type(user_module) == "table"

const user_benchmark_fn = (is_function and user_module) or (is_table and user_module.bench)

if type(user_benchmark_fn) ~= "function" then
	error("Benchmark file must return a function or a table with a 'bench' function.")
end

const warmup_count = (is_table and type(user_module.warmup) == "number" and user_module.warmup) or {{WARMUP}}
const samples_count = (is_table and type(user_module.samples) == "number" and user_module.samples) or {{SAMPLES}}

for i = 1, warmup_count do
	user_benchmark_fn()
end

const samples = table.create(samples_count)

for i = 1, samples_count do
	const start = os.clock()
	user_benchmark_fn()
	const elapsed = os.clock() - start
	samples[i] = elapsed * 1000
end

table.sort(samples)

local total = 0
for _, t in samples do
	total += t
end

const mean = total / samples_count
const p0 = samples[1]
const p50 = samples[math.max(1, math.floor(samples_count * 0.50))]
const p90 = samples[math.max(1, math.floor(samples_count * 0.90))]
const p95 = samples[math.max(1, math.floor(samples_count * 0.95))]
const p100 = samples[samples_count]

const result = {
	mean = mean,
	p0 = p0,
	p50 = p50,
	p90 = p90,
	p95 = p95,
	p100 = p100,
	samples_count = samples_count,
	warmup_count = warmup_count,
}

return HttpService:JSONEncode(result)
]]
