# Project Overview

**rbxperf** — CLI for benchmarking and detecting performance regressions in Roblox projects.

The tool is intended to run test scenarios inside the engine, collect metrics such as frame time via rbxmp, execute multiple samples, and compare the results against a baseline. It calculates metrics such as p50/p95/p99 and can fail CI when a change exceeds the configured regression threshold.

## Reference Projects

- [Criterion.rs](https://github.com/criterion-rs/criterion.rs) — statistical sampling, regression detection, and baseline comparisons.
- [Hyperfine](https://github.com/sharkdp/hyperfine) — CLI design, warmups, repeated runs, outlier detection, and result exports.
- [Bencher](https://github.com/bencherdev/bencher) — continuous benchmarking, historical results, CI integration, thresholds, and regression policies.

## Public Distribution Strategy

The project will initially distribute only the CLI as its supported public interface because it provides a more ergonomic user experience for the primary workflow. The runtime-agnostic library will remain an internal implementation detail at first.

If enough use cases emerge that require highly specialized workflows, the library should be distributed through an appropriate package manager so users can build programmatic integrations around their own workflows.
