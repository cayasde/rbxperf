# rbxperf

**A Surgical Performance Regression CLI for Roblox Engine.**

> [!WARNING]
> **Work In Progress:** This project is nowhere near where I want it to be yet, and will go through some heavy and cool evolutions. Currently, I am busy developing games, so I haven't had the time to finish the standalone CLI or polish the codebase. I strongly do not recommend using this in production, as it doesn't currently do enough useful things for you to even consider relying on it. Breaking changes are expected and acceptable in this phase.

`rbxperf` is a specialized, zero-overhead benchmarking tool that runs your code exactly where it matters: inside live Roblox servers via Open Cloud. It detects latency spikes, calculates statistical percentiles (P50, P95, P99), and strictly protects your architecture from performance regressions in CI/CD environments.

## Architecture & Philosophy

### Quality Over Quantity (The 5 RPM & 30 RPH)

Roblox Open Cloud enforces strict hardware limits to prevent abuse. Our tool operates under the following official and shadow constraints (see [Luau Execution API](https://create.roblox.com/docs/cloud/reference/features/luau-execution)):

- `MAX_CONCURRENT_TASKS = 10`
- `REQUESTS_PER_MINUTE = 5`
- `REQUESTS_PER_HOUR = 30`
- `MAX_EXECUTION_TIME_SECONDS = 300` (5 minutes)

**Philosophy:** You should **not** write benchmarks for trivial functions or every single method in your codebase. `rbxperf` is designed exclusively for **highly critical execution paths**.

This is a mathematical constraint imposed by the engine, not an opinionated guideline. Since Open Cloud rate-limits execution to 5 requests per minute and ~30 requests per hour, a suite of just 50 benchmarks will artificially halt your CI/CD pipeline for **~68 minutes** due to forced throttling and API lockouts.

### The Execution Algorithm

We explicitly **do not batch** multiple benchmark files into a single network request. _(Wait, I really want to batch my benchmarks! Fine, see [Manual Batching (At Your Own Risk)](#manual-batching-at-your-own-risk))._
Doing so would result in severe Memory Pollution (Garbage Collection from Benchmark A artificially increasing the latency of Benchmark B).

Our algorithm guarantees **Sterile Isolation**:

1. **Discovery:** Scans your project for `.bench.luau` files.
2. **Payload Injection:** Wraps your function in a warmup loop.
3. **Execution:** Dispatches the script to Roblox Open Cloud.
4. **Throttling:** We strictly adhere to the Quotas. The runner calculates your ETA and automatically pauses execution (sleeping for 60 seconds every 5 tasks, and 1 hour every 30 tasks) to guarantee that each benchmark runs in a virgin memory state without hitting `HTTP 429` lockouts.
5. **Statistical Extraction:** We return and paint the distribution percentiles, catching the "Coordinated Omission" problem where standard averages hide catastrophic tail latencies.

## Writing Benchmarks

A benchmark is simply a `.bench.luau` file that returns a function. `rbxperf` will automatically discover and execute it inside the engine.

```luau
-- math.bench.luau
return function()
	local x = 0
	for i = 1, 1000 do
		x += math.sqrt(i)
	end
end
```

## Manual Batching (At Your Own Risk)

Because of our Sterile Isolation philosophy, `rbxperf` will **never** natively support batching multiple `.bench.luau` files together to bypass the Open Cloud rate limits.

However, if you absolutely must bypass the quotas and are willing to accept the severe memory pollution risks, you can manually compose your benchmarks. Nobody will stop you from creating a single `runner.bench.luau` that requires your internal modules and calls them sequentially:

```luau
-- runner.bench.luau
local bench_physics = require(script.Parent.physics)
local bench_math = require(script.Parent.math)

return function()
	bench_physics()
	bench_math()
end
```

By doing this, you consolidate your entire suite into a single network request. Just be aware that any latency spikes reported for `bench_math` might actually be the Engine Garbage Collector cleaning up the mess left behind by `bench_physics`. You have been warned!

## Roadmap

### MicroProfiler & Memory Analysis

Because `rbxperf` injects payloads directly into the live Roblox VM (rather than simulating them externally), we have native access to deep engine metrics.

Future versions of this tool will integrate the [`rbxmp` / `libmp`](https://github.com/Roblox/libmp) module (MicroProfiler) and garbage collection hooks to provide:

1. **Memory Tracking:** Exact byte allocations isolated by thread, captured directly via `CounterIterator` and `CounterDesc` objects, completely bypassing the unpredictable heuristics of Lua `gcinfo()`.
2. **CPU/GPU Profiling:** Real engine frame-times extracted via `Session:GetFrameDesc()` instead of just `os.clock()` wall-time.
3. **Bottleneck Identification:** Flagging whether a P99 latency spike was caused by pure algorithmic complexity or a sudden Garbage Collection stall, verified by traversing the engine stack via `LogIterator`.
4. **Reliable Native Batching (Blocked):** Native batching requires the Roblox runtime to expose a documented, CI-compatible isolation boundary, ideally a fresh Luau VM or process per benchmark, with independent memory and GC accounting, plus a way to verify that boundary. Until those engine guarantees exist, benchmarks must remain in separate Open Cloud executions to preserve the Sterile Isolation philosophy.

### Lute Runtime Support

While `rbxperf` is fundamentally designed to protect live Roblox experiences, future versions will introduce native support for the **Lute runtime**.

This caters to developers building infrastructure, CLI tooling, or headless libraries that don't require the Roblox engine overhead but still demand rigorous regression testing.

**We will strictly NOT support community runtimes (Lune, Zune, etc).**
The rationale is twofold:

1. **Official Authority:** Lute is the official standalone runtime maintained by the Luau language team.
2. **Scope Discipline:** Attempting to maintain wrappers, APIs, and quirks for every community-forked runtime introduces unnecessary maintenance overhead and scope creep. We will restrict our support surface strictly to the official engines: Roblox Open Cloud and Lute.

### CLI Distribution

In the future, the `rbxperf` CLI will be compiled and distributed via GitHub Releases for **Windows, macOS, and Linux**. It will be fully installable and manageable through standard development toolchains like `rokit` and `mise`, allowing seamless integration into any CI/CD environment without manual scripting.
