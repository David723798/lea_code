## 0.0.7

- Replaced the older file and web tool set with a larger runtime-managed tool suite: `read`, `write`, `edit`, `glob`, `grep`, `sleep`, `powershell`, `ask_user_question`, `task_create`, `task_update`, `task_list`, `list_mcp_resources`, and `read_mcp_resource`.
- Added `ToolRuntime` to track workspace state, remembered file reads, the current working directory, session tasks, approval requests, and interactive multiple-choice questions.
- Updated `bash` so it runs in the workspace, supports `workdir` and `timeout_ms`, formats structured command output, and requests approval for mutating, networked, or otherwise non-read-only commands.
- Replaced generated schema-backed tool input models with lightweight JSON schema helpers and removed the old generated files from `lib/models/`.
- Added tests for command safety rules and runtime file/task behavior.
- Bumped the package version from `0.0.6` to `0.0.7`.

## 0.0.6

- Added OpenAI provider support via `genkit_openai`.
- Added `--provider` / `-p` to choose between `google` (default) and `openai`.
- Added `--api_key` / `-k` and `--base_url` / `-b` for provider configuration.
- Added `--help` / `-h` and `--version` / `-v`.
- Made `--system_prompt` optional and routed it through the agent as output instructions.
- Bumped the package version from `0.0.5` to `0.0.6`.

## 0.0.5

- Refactored the CLI around new `LeaCode` and `GeneralAgent` classes, replacing `LeaCodeEngine`.
- Added a new `file_edit` tool backed by `sed` for in-place file edits.
- Added tool status messaging so tool start and completion updates are shown in the terminal.
- Added a `--max_turns` / `-t` CLI option to control the maximum number of model turns per request.
- Changed the installed executable from `lea_code` to `lea`.
- Bumped the package version from `0.0.3` to `0.0.5`.

## 0.0.3

- Added a new `web_fetch` tool so the assistant can fetch web pages as text.
- Registered `web_fetch` in `LeaCodeEngine` so it is available during model generation.
- Bumped the package version from `0.0.2` to `0.0.3`.

## 0.0.2

- Bumped the package version from `0.0.1` to `0.0.2`.

## 0.0.1

- Added the initial `lea_code` interactive CLI entrypoint.
- Added Gemini-powered response generation through Genkit and `genkit_google_genai`.
- Added support for selecting a model with `--model`.
- Added support for passing a custom system prompt with `--system_prompt`.
- Added conversation management commands for resetting and exiting the session.
- Added local assistant tools for shell execution, file reads, file writes, string search, and file discovery.
- Added typed tool input models and generated schema files for tool registration.
