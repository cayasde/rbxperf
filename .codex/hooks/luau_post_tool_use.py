#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import TypeGuard

PATCH_PATH_PATTERN = re.compile(
	r"^\*\*\* (?:Add File|Update File|Move to|Delete File):\s*(.*?)\s*$"
)


def add_luau_path(paths: list[str], candidate: object) -> None:
	if not isinstance(candidate, str) or not candidate.lower().endswith(".luau"):
		return

	paths.append(candidate)


def append_patch_paths(paths: list[str], patch: str) -> None:
	for line in patch.splitlines():
		match = PATCH_PATH_PATTERN.match(line)
		if match is not None:
			add_luau_path(paths, match.group(1))


def is_json_object(value: object) -> TypeGuard[dict[str, object]]:
	return isinstance(value, dict)


def fail(message: str) -> int:
	print(message, file=sys.stderr)
	return 1


def main() -> int:
	payload = sys.stdin.read()
	if not payload:
		return 0

	try:
		event: object = json.loads(payload)
	except json.JSONDecodeError as error:
		return fail(f"Invalid hook event JSON: {error}")

	if not is_json_object(event):
		return 0

	tool_input = event.get("tool_input")
	if not is_json_object(tool_input):
		return 0

	changed_paths: list[str] = []
	patch = tool_input.get("command")
	if isinstance(patch, str):
		append_patch_paths(changed_paths, patch)

	for property_name in ("file_path", "path", "filename"):
		add_luau_path(changed_paths, tool_input.get(property_name))

	if not changed_paths:
		return 0

	event_cwd = event.get("cwd")
	session_cwd = Path(event_cwd).resolve() if isinstance(event_cwd, str) else Path.cwd()

	try:
		git_result = subprocess.run(
			["git", "-C", str(session_cwd), "rev-parse", "--show-toplevel"],
			check=False,
			capture_output=True,
			text=True,
		)
	except OSError:
		return 0

	if git_result.returncode != 0:
		return 0

	repo_root_text = git_result.stdout.strip()
	if not repo_root_text:
		return 0

	repo_root = Path(repo_root_text).resolve()
	package_root = (repo_root / "rbxperf").resolve()
	config_path = package_root / "stylua.toml"
	if not config_path.is_file():
		return fail(f"StyLua configuration not found: {config_path}")

	format_paths: list[str] = []
	seen_paths: set[str] = set()
	should_analyze = False

	for changed_path in changed_paths:
		full_path = (session_cwd / changed_path).resolve()

		try:
			relative_path = full_path.relative_to(package_root)
		except ValueError:
			continue

		normalized_relative_path = relative_path.as_posix()
		if not normalized_relative_path.lower().endswith(".luau"):
			continue
		if relative_path.parts[0].casefold() in {"src", "tests"}:
			should_analyze = True
		if not full_path.is_file():
			continue

		path_key = os.path.normcase(normalized_relative_path)
		if path_key in seen_paths:
			continue

		seen_paths.add(path_key)
		format_paths.append(normalized_relative_path)

	if not format_paths and not should_analyze:
		return 0

	mise_executable = "mise.exe" if os.name == "nt" else "mise"
	if format_paths:
		try:
			stylua_lookup = subprocess.run(
				[mise_executable, "which", "stylua"],
				cwd=package_root,
				check=False,
				capture_output=True,
				text=True,
			)
		except OSError as error:
			return fail(f"Failed to run mise which stylua: {error}")

		if stylua_lookup.returncode != 0:
			return fail(f"mise which stylua failed: {stylua_lookup.stderr.strip()}")

		stylua_executable = stylua_lookup.stdout.strip()
		if not stylua_executable:
			return fail("mise which stylua returned an empty executable path")

		formatter_arguments = [
			stylua_executable,
			"--respect-ignores",
			"--config-path",
			str(config_path),
			*format_paths,
		]
		try:
			formatter_result = subprocess.run(
				formatter_arguments,
				cwd=package_root,
				check=False,
			)
		except OSError as error:
			return fail(f"Failed to run StyLua: {error}")

		if formatter_result.returncode != 0:
			return formatter_result.returncode

	if should_analyze:
		try:
			analysis_result = subprocess.run(
				[mise_executable, "run", "--cd", str(repo_root), "analyze"],
				cwd=package_root,
				check=False,
			)
		except OSError as error:
			return fail(f"Failed to run mise run analyze: {error}")

		return analysis_result.returncode

	return 0


if __name__ == "__main__":
	raise SystemExit(main())
