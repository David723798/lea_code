# lea_code

`lea_code` is a Dart command-line coding assistant powered by Genkit. It runs as an interactive terminal chat and gives the model a set of local file, shell, and web tools so it can inspect and modify code in your working directory.

## Features

- Interactive CLI chat loop
- Provider selection (Google or OpenAI)
- Model selection via a command-line flag
- Optional custom system prompt
- Configurable max tool-calling turns per response
- Conversation reset with `/new`
- Built-in tools for:
  - running shell commands
  - reading files
  - writing files
  - editing files with `sed`
  - searching file contents
  - finding files by name
  - fetching web pages as readable text
- Inline tool status messages while the assistant works

## Requirements

- Dart SDK `^3.11.4`
- API access:
  - Google: a Google AI key
  - OpenAI: an OpenAI-compatible key (optionally with a custom base URL)
- `curl` available on your system for the `web_fetch` tool

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
  --provider google \
  --model gemini-flash-lite-latest \
  --system_prompt "You are a careful coding assistant."
```

OpenAI example:

```bash
lea \
  --provider openai \
  --model gpt-4.1-mini \
  --api_key "$OPENAI_API_KEY"
```

OpenAI-compatible base URL example:

```bash
lea \
  --provider openai \
  --model gpt-4.1-mini \
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

The assistant registers seven tools through `GeneralAgent`:

- `bash`: executes a shell command with `bash -c`
- `file_read`: reads a file from disk
- `file_write`: writes content to a file
- `file_edit`: edits a file using a `sed` command
- `string_search`: searches the current directory with `grep -r`
- `file_find`: finds files and directories with `find`
- `web_fetch`: fetches a URL

Tool usage is surfaced in the terminal as status messages like `[bash] ...` and `[bash] completed`.

These tools operate on the local machine, so use this project only in directories and environments you trust.

## Project Structure

- `bin/lea_code.dart`: CLI entrypoint and REPL loop
- `lib/lea_code.dart`: top-level application flow and terminal messaging
- `lib/agents/general_agent.dart`: Genkit setup and tool registration
- `lib/tools/`: tool definitions exposed to the model
- `lib/models/`: typed tool input models and generated schema files

## Notes

- API keys are passed via `--api_key` (provider-dependent). You can still source them from environment variables in your shell (e.g. `--api_key "$OPENAI_API_KEY"`).
- Tool output is returned directly to the model, including shell stderr when present.
- The installed executable is `lea`.
- `string_search` and `file_find` run relative to the current working directory.
- `file_edit` runs `sed -i ''`, matching BSD/macOS `sed` behavior.
- `web_fetch` returns text fetched from the target page.
