# lea_code

`lea_code` is a Dart command-line coding assistant powered by Genkit. It runs as an interactive terminal chat and gives the model a set of local workspace tools so it can inspect files, edit code, run commands, ask for approval, and manage lightweight session state while working in your project.

## Features

- Interactive CLI chat loop
- Three-stage agent workflow with separate analysis, execution, and verification passes
- Provider selection for Google or OpenAI-compatible backends
- Model selection via a command-line flag
- Optional custom system prompt
- Configurable max tool-calling turns per response
- Automatic verification retries for failed execution attempts
- Conversation reset with `/new`
- Runtime-managed tools for:
  - reading numbered file content from absolute paths
  - writing and editing workspace files with read-before-write safety checks
  - running shell commands in the workspace with approval prompts for risky commands
  - searching code with `rg` and file name matching with `find`
  - asking the user multiple-choice questions during a session
  - creating and updating in-session tasks
  - listing and reading MCP resources when an MCP adapter is configured
  - sleeping / waiting and running PowerShell commands when needed
- Inline tool status messages while the assistant works

## Requirements

- Dart SDK `^3.11.4`
- API access:
  - Google: a Google AI key
  - OpenAI: an OpenAI-compatible key (optionally with a custom base URL)
- `rg` (ripgrep) available on your system for the `grep` tool
- PowerShell is optional and only needed for the `powershell` tool

## Install

```bash
dart pub global activate lea_code
```

## Run

```bash
lea
```

You can also choose a provider, model, and provide a system prompt:

```bash
lea \
  --provider openai \
  --model gpt-5.4 \
  --system_prompt "You are a careful coding assistant."
```

OpenAI example:

```bash
lea \
  --provider openai \
  --model gpt-5.4 \
  --api_key "$OPENAI_API_KEY"
```

OpenAI-compatible base URL example:

```bash
lea \
  --provider openai \
  --model gpt-5.4 \
  --base_url "http://localhost:11434/v1" \
  --api_key "your-key-if-needed"
```

You can also control how many model turns are allowed while using tools:

```bash
lea --max_turns 100
```

## CLI Options

- `-p`, `--provider`: Provider to use. One of `google` or `openai`. Defaults to `google`.
- `-m`, `--model`: Model name to use. Defaults to `gemini-flash-lite-latest`.
- `-k`, `--api_key`: API key to use (provider-dependent).
- `-b`, `--base_url`: Base URL to use (primarily for `openai`).
- `-s`, `--system_prompt`: Optional system prompt passed as output instructions.
- `-t`, `--max_turns`: Maximum number of turns the model can use in a conversation step. Defaults to `100`.
- `-h`, `--help`: Show help.
- `-v`, `--version`: Show version.

## Interactive Commands

- `/new`: clear the current conversation history
- `/exit`: quit the program

## Built-in Tools

The assistant exposes its tools through stage-specific agents built on `BaseAgent`:

- `AnalysisAgent`: read-oriented planning before any edits are made
- `ExecuteAgent`: full tool access for making the requested changes
- `VerifyAgent`: read-oriented validation and final response generation

The full tool set includes fourteen tools:

- `powershell`: runs a PowerShell command when PowerShell is available
- `glob`: finds files by wildcard pattern using `find`
- `grep`: searches file contents with `rg`
- `sleep`: waits for a requested duration
- `bash`: runs a shell command in the workspace, with approval checks for risky commands
- `read`: reads a text file from an absolute path and returns numbered lines
- `edit`: edits an existing file using exact string replacements
- `write`: writes a file inside the workspace
- `ask_user_question`: asks the user one to three multiple-choice questions
- `task_create`: creates a task in the current session
- `task_update`: updates an existing session task
- `task_list`: lists session tasks
- `list_mcp_resources`: lists resources from the configured MCP backend
- `read_mcp_resource`: reads a specific MCP resource

Tool usage is surfaced in the terminal as status messages like `[bash] ...` and `[bash] completed`.

The runtime tracks files that have been read so `edit` and `write` can reject stale overwrites, keeps commands inside the workspace, and can pause for explicit approval before mutating or networked shell commands. These tools operate on the local machine, so use this project only in directories and environments you trust.

Each request now flows through three model stages. The analysis stage inspects the request and prepares a plan without modifying files, the execution stage applies changes, and the verification stage checks whether the request is fully satisfied. When verification fails, Lea Code can retry execution with verifier feedback for up to three attempts before returning the final response.

## Project Structure

- `bin/lea_code.dart`: CLI entrypoint and REPL loop
- `lib/lea_code.dart`: top-level application flow, staged agent orchestration, approval prompts, and question handling
- `lib/agents/base_agent.dart`: shared Genkit wrapper and reusable tool-set mixins
- `lib/agents/analysis_agent.dart`: read-only planning agent
- `lib/agents/execute_agent.dart`: execution agent with editing tools
- `lib/agents/verify_agent.dart`: read-only verification agent
- `lib/agents/general_agent.dart`: compatibility export for agent classes
- `lib/tools/`: tool definitions exposed to the model
- `lib/tools/runtime/`: shared runtime for file tracking, task state, and approvals
- `lib/tools/models/`: runtime model classes shared across tools
- `lib/tools/utils/`: command safety and JSON schema helper utilities

## Notes

- API keys are passed via `--api_key` (provider-dependent). You can still source them from environment variables in your shell (e.g. `--api_key "$OPENAI_API_KEY"`).
- Tool output is returned directly to the model, including shell stderr when present.
- The installed executable is `lea`.
- `read`, `write`, and `edit` expect absolute file paths.
- `grep` uses `rg`, and `glob` uses `find`.
- `edit` and overwriting `write` operations require the file to be read first in the current session.
- `bash` supports optional `workdir` and `timeout_ms` inputs and prompts for approval when a command looks mutating, networked, or otherwise non-read-only.
- MCP resource tools return an error unless an MCP adapter is configured for the session.
