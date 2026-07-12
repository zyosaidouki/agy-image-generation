#!/usr/bin/env bash
set -euo pipefail

skill_name="agy-image-generation"

usage() {
  printf '%s\n' \
    "Usage: bash setup.sh [options]" \
    "" \
    "Install the ${skill_name} Codex skill into a Codex skills directory." \
    "" \
    "Options:" \
    "  --check           Show detected paths and dependency status without installing." \
    "  --force           Overwrite files if the skill is already installed." \
    "  --global          Install into CODEX_HOME/skills or ~/.codex/skills." \
    "  --local           Install into ./.codex/skills next to this repository." \
    "  --dest DIR        Install into DIR and skip scope selection." \
    "  -h, --help        Show this help." \
    "" \
    "Examples:" \
    "  bash setup.sh" \
    "  bash setup.sh --check" \
    "  bash setup.sh --local" \
    "  bash setup.sh --force" \
    "  bash setup.sh --dest \"\$HOME/.codex/skills\""
}

script_path=${BASH_SOURCE[0]}
case $script_path in
  */*) script_path=${script_path%/*} ;;
  *) script_path=. ;;
esac

script_dir=$(cd -- "$script_path" && pwd)

if [[ -n "${CODEX_HOME:-}" ]]; then
  global_dest_root="${CODEX_HOME}/skills"
else
  global_dest_root="${HOME}/.codex/skills"
fi
local_dest_root="${script_dir}/.codex/skills"

dest_root=""
scope=""
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
    --global)
      if [[ -n "$scope" ]]; then
        echo "error: choose only one install scope" >&2
        exit 2
      fi
      scope="global"
      shift
      ;;
    --local)
      if [[ -n "$scope" ]]; then
        echo "error: choose only one install scope" >&2
        exit 2
      fi
      scope="local"
      shift
      ;;
    --dest)
      if [ "$#" -lt 2 ]; then
        echo "error: --dest requires a directory" >&2
        exit 2
      fi
      if [[ -n "$scope" ]]; then
        echo "error: --dest cannot be combined with --global or --local" >&2
        exit 2
      fi
      dest_root=$2
      scope="custom"
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

if [[ -z "$scope" ]]; then
  if [[ -t 0 ]]; then
    printf '%s\n' "Choose install scope:"
    printf '%s\n' "  1) global: ${global_dest_root}"
    printf '%s\n' "  2) local:  ${local_dest_root}"
    printf '%s' "Install globally? [Y/n]: "
    read -r answer
    case "${answer:-y}" in
      y|Y|yes|YES|Yes|1|"")
        scope="global"
        ;;
      n|N|no|NO|No|2)
        scope="local"
        ;;
      *)
        echo "error: enter y for global or n for local" >&2
        exit 2
        ;;
    esac
  else
    echo "error: no install scope supplied and stdin is not interactive" >&2
    echo "Run with --global, --local, or --dest DIR." >&2
    exit 2
  fi
fi

case "$scope" in
  global)
    dest_root=$global_dest_root
    ;;
  local)
    dest_root=$local_dest_root
    ;;
  custom)
    ;;
  *)
    echo "error: invalid install scope: $scope" >&2
    exit 2
    ;;
esac

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
echo "Scope: ${scope}"
echo "Global target root: ${global_dest_root}"
echo "Local target root: ${local_dest_root}"
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
