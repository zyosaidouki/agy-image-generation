---
name: agy-image-generation
description: Generate raster images by delegating image creation to the local agy CLI from Codex CLI. Use when the user asks Codex to create, generate, render, or iterate on images, visual assets, concept art, thumbnails, illustrations, product mockups, sprites, or other bitmap outputs and the intended executor is agy CLI rather than an in-process image model, SVG, HTML/CSS, or hand-authored drawing code.
---

# AGY Image Generation

## Overview

Use the local `agy` command as the source of truth for image generation on any OS supported by Codex CLI. Codex's role is to translate the user's visual intent into a precise prompt, run `agy` with the current shell's path conventions, verify the output file exists, and report the saved path.

## Workflow

1. Capture the image brief: subject, style, mood, composition, aspect ratio, size, number of images, text to include or avoid, and target output path. Ask a concise follow-up only when a missing detail would materially change the result.
2. Keep generated files inside the current workspace unless the user gives another writable path. Use OS-appropriate path syntax and quote paths that contain spaces.
3. Confirm `agy` is available with `agy --version`, `agy version`, or the current platform's command lookup (`command -v agy` on Linux/macOS shells, `Get-Command agy` on PowerShell). If it is missing, stop and tell the user that the skill requires the agy CLI to be installed or added to `PATH`.
4. Inspect the installed command contract before the first generation in a session:
   - Run `agy --help`.
   - If image generation is not visible, inspect likely subcommands such as `agy image --help`, `agy generate --help`, `agy img --help`, or `agy run --help`.
   - Treat the local help output as authoritative because agy CLI flags may vary by version.
5. Generate the image through `agy` only. Do not switch to another image generator unless the user explicitly asks for a fallback.
6. Prefer non-interactive, file-producing commands. Provide the prompt and output path through documented flags when available. If only an interactive mode exists, use the documented non-interactive equivalent or explain the limitation.
7. Verify the result by checking that the output file exists and is non-empty. For visual quality-sensitive work, open or inspect the image when tools are available.
8. Return the absolute path of the generated image and mention any notable constraints, such as omitted unsupported options.

## Prompt Construction

Write prompts in the language most useful to the model behind `agy`. If the user speaks Japanese and gives no preference, keep the user-facing conversation in Japanese but use a concise English generation prompt when image models are likely to follow it better.

Include:

- Primary subject and scene
- Medium or style
- Camera or composition details when relevant
- Lighting, color, and mood
- Aspect ratio or dimensions
- Negative constraints only if `agy` supports them

Avoid promising exact text rendering, exact likenesses, or exact brand/logo fidelity unless agy's help or the user's references make that capability clear.

## Command Pattern

Because agy CLI syntax and shell quoting are environment-specific, derive the final command from local help. Common shapes to look for:

```sh
agy image generate --prompt "..." --output "./generated-images/example.png"
agy generate image --prompt "..." --out "./generated-images/example.png"
agy run image --prompt "..." --save "./generated-images/example.png"
```

Use the exact installed syntax, not these examples, when local help differs. On Windows, PowerShell, Linux, and macOS, prefer relative workspace paths such as `./generated-images/example.png` when the CLI accepts them; otherwise resolve an absolute path using the host OS conventions.

## Iteration

When the user asks for revisions, preserve the previous prompt and output path history in your reasoning, then create a new filename rather than overwriting unless the user asks to replace the file. If agy supports image-to-image or reference-image options, use them for edits to an existing generated image; otherwise, regenerate with a revised text prompt and explain that it is a fresh generation.

## Reference

Read `references/agy-cli-discovery.md` when `agy --help` is unclear, the output path is not obvious, or you need a compact checklist for mapping the user's request to CLI flags.
