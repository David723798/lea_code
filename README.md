# lea_code

`lea_code` is a Dart command-line coding assistant powered by Genkit and Google Gemini. It runs as an interactive terminal chat and gives the model a small set of local file and shell tools so it can inspect and modify code in your working directory.

## Features

- Interactive CLI chat loop
- Google Gemini model selection via a command-line flag
- Optional custom system prompt
- Conversation reset with `/new`
- Built-in tools for:
  - running shell commands
  - reading files
  - writing files
  - searching file contents
  - finding files by name

## Requirements

- Dart SDK `^3.11.4`
- A Google AI API key exposed as either `GOOGLE_GENAI_API_KEY` or `GEMINI_API_KEY`

## Install

```bash
dart pub global activate lea_code
```

## Run

```bash
lea_code
```

You can also choose a model and provide a system prompt:

```bash
lea_code \
  --model gemini-flash-lite-latest \
  --system_prompt "You are a careful coding assistant."
```

## CLI Options

- `-m`, `--model`: Gemini model name to use. Defaults to `gemini-flash-lite-latest`.
- `-s`, `--system_prompt`: Optional system prompt passed as output instructions.

## Interactive Commands

- `/new`: clear the current conversation history
- `/exit`: quit the program
- `/quit`: quit the program

## Built-in Tools

The assistant registers five tools in `LeaCodeEngine`:

- `bash`: executes a shell command with `bash -c`
- `file_read`: reads a file from disk
- `file_write`: writes content to a file
- `string_search`: searches the current directory with `grep -r`
- `file_find`: finds files and directories with `find`

These tools operate on the local machine, so use this project only in directories and environments you trust.

## Project Structure

- `bin/lea_code.dart`: CLI entrypoint and REPL loop
- `lib/lea_code_engine.dart`: Genkit setup and tool registration
- `lib/tools/`: tool definitions exposed to the model
- `lib/models/`: typed tool input models and generated schema files

## Notes

- The application exits early if neither `GOOGLE_GENAI_API_KEY` nor `GEMINI_API_KEY` is set.
- Tool output is returned directly to the model, including shell stderr when present.
- `string_search` and `file_find` run relative to the current working directory.
