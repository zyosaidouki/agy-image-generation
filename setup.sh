#!/bin/sh
set -eu

skill_name="agy-image-generation"

usage() {
  printf '%s\n' \
    "Usage: sh setup.sh [options]" \
    "" \
    "Install the ${skill_name} Codex skill into your local Codex skills directory." \
    "" \
    "Options:" \
    "  --check           Show detected paths and dependency status without installing." \
    "  --force           Overwrite files if the skill is already installed." \
    "  --dest DIR        Install into DIR instead of CODEX_HOME/skills or ~/.codex/skills." \
    "  -h, --help        Show this help." \
    "" \
    "Examples:" \
    "  sh setup.sh" \
    "  sh setup.sh --check" \
    "  sh setup.sh --force" \
    "  sh setup.sh --dest \"\$HOME/.codex/skills\""
}

case $0 in
  */*) script_path=${0%/*} ;;
  *) script_path=. ;;
esac

script_dir=$(CDPATH= cd -- "$script_path" && pwd)

if [ -n "${CODEX_HOME:-}" ]; then
  default_dest_root="${CODEX_HOME}/skills"
else
  default_dest_root="${HOME}/.codex/skills"
fi

dest_root=$default_dest_root
force=0
check_only=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)
      check_only=1
      shift
      ;;
    --force)
      force=1
      shift
      ;;
    --dest)
      if [ "$#" -lt 2 ]; then
        echo "error: --dest requires a directory" >&2
        exit 2
      fi
      dest_root=$2
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

dest_dir="${dest_root}/${skill_name}"

require_file() {
  if [ ! -e "$1" ]; then
    echo "error: required file is missing: $1" >&2
    exit 1
  fi
}

require_file "${script_dir}/SKILL.md"
require_file "${script_dir}/README.md"
require_file "${script_dir}/agents/openai.yaml"
require_file "${script_dir}/references/agy-cli-discovery.md"

echo "Skill: ${skill_name}"
echo "Source: ${script_dir}"
echo "Target: ${dest_dir}"

if command -v agy >/dev/null 2>&1; then
  echo "agy: found ($(command -v agy))"
else
  echo "agy: not found in PATH"
  echo "note: install agy CLI before using this skill to generate images."
fi

if [ "$check_only" -eq 1 ]; then
  exit 0
fi

if [ -e "$dest_dir" ] && [ "$force" -ne 1 ]; then
  echo "error: target already exists: ${dest_dir}" >&2
  echo "Run with --force to overwrite the skill files." >&2
  exit 1
fi

mkdir -p "${dest_dir}/agents" "${dest_dir}/references"

cp "${script_dir}/SKILL.md" "${dest_dir}/SKILL.md"
cp "${script_dir}/README.md" "${dest_dir}/README.md"
cp "${script_dir}/agents/openai.yaml" "${dest_dir}/agents/openai.yaml"
cp "${script_dir}/references/agy-cli-discovery.md" "${dest_dir}/references/agy-cli-discovery.md"

echo "Installed ${skill_name} to ${dest_dir}"
echo "Try: Use \$${skill_name} to generate an image with agy CLI."
