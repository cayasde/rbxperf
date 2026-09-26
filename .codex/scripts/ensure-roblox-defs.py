#!/usr/bin/env python3
import sys
import tempfile
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

CODEX_DIRECTORY = Path(__file__).resolve().parents[1]
ROBLOX_DEFINITIONS_PATH = CODEX_DIRECTORY / "roblox.d.luau"
ROBLOX_DEFINITIONS_URL = (
	"https://luau-lsp.pages.dev/type-definitions/globalTypes.None.d.luau"
)


def fail(message: str) -> int:
	print(message, file=sys.stderr)
	return 1


def main() -> int:
	if ROBLOX_DEFINITIONS_PATH.is_file():
		try:
			if ROBLOX_DEFINITIONS_PATH.stat().st_size > 0:
				print("Roblox definitions are already installed.")
				return 0
		except OSError as error:
			return fail(f"Could not inspect Roblox definitions: {error}")

	print("Downloading Roblox definitions...")

	try:
		request = Request(
			ROBLOX_DEFINITIONS_URL,
			headers={"User-Agent": "rbxperf"},
		)
		with urlopen(request, timeout=30) as response:
			if not 200 <= response.status < 300:
				return fail(
					"Could not download Roblox definitions "
					f"(HTTP {response.status} {response.reason})."
				)
			definitions = response.read()
	except HTTPError as error:
		return fail(
			"Could not download Roblox definitions "
			f"(HTTP {error.code} {error.reason})."
		)
	except (TimeoutError, URLError, OSError) as error:
		return fail(f"Could not download Roblox definitions: {error}")

	if not definitions.strip():
		return fail("Could not download Roblox definitions: the response body is empty.")

	temporary_path: Path | None = None
	try:
		with tempfile.NamedTemporaryFile(
			dir=CODEX_DIRECTORY,
			prefix=".roblox.d.luau.",
			suffix=".tmp",
			delete=False,
		) as temporary_file:
			temporary_path = Path(temporary_file.name)
			temporary_file.write(definitions)
		temporary_path.replace(ROBLOX_DEFINITIONS_PATH)
	except OSError as error:
		if temporary_path is not None:
			try:
				temporary_path.unlink(missing_ok=True)
			except OSError:
				pass
		return fail(f"Could not install Roblox definitions: {error}")

	print(f"Roblox definitions installed at {ROBLOX_DEFINITIONS_PATH}.")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
