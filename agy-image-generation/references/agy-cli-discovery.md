# AGY CLI Discovery

Use this reference only when the installed `agy` command's syntax is unclear.

## Discovery Checklist

1. Check availability:
   - POSIX shells on Linux/macOS: `command -v agy`
   - PowerShell on Windows/macOS/Linux: `Get-Command agy`
   - Any shell after command discovery: `agy --version` or `agy version`
2. Read top-level help:
   - `agy --help`
3. Find image-generation subcommands:
   - `agy image --help`
   - `agy images --help`
   - `agy generate --help`
   - `agy img --help`
   - `agy run --help`
4. Identify documented options for:
   - prompt text
   - output path or output directory
   - model
   - size, width, height, or aspect ratio
   - count or batch size
   - seed
   - reference image or image-to-image input
   - negative prompt
   - overwrite behavior
5. Prefer a command that exits after writing files. Avoid interactive shells for Codex CLI automation.

## Mapping User Intent To Flags

Map only options supported by local help:

- "square", "portrait", "landscape", or social media targets: aspect ratio, width, height, or size flags.
- "make 4 options": count, batch, or repeat the command with numbered outputs.
- "same style as this image": reference-image, init-image, or image-to-image flags.
- "do not include text/hands/logo": negative prompt if supported; otherwise include it as a constraint in the main prompt.
- "transparent background": transparent, background, alpha, or PNG options if supported.

## Output Naming

Use stable, descriptive filenames:

```text
generated-images/
  subject-style-001.png
  subject-style-002.png
```

Create the output directory before generation when the CLI does not create it automatically. Never overwrite an existing output unless the user explicitly asks.

## Cross-Platform Notes

Prefer workspace-relative output paths such as `./generated-images/subject-style-001.png`. They are easier for Codex CLI to reuse across Linux, macOS, and Windows.

When absolute paths are required, construct them using the host OS conventions:

- Linux/macOS: `/home/user/project/generated-images/example.png`
- Windows PowerShell: `C:\Users\user\project\generated-images\example.png`

Quote all paths that may contain spaces. Avoid assuming that the active shell is Bash, zsh, PowerShell, or cmd; inspect the environment and use the syntax that matches the current session.
