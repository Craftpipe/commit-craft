#!/usr/bin/env bash

set -e

usage() {
  cat <<EOF
commit-craft - Generate conventional commits from staged changes

USAGE:
  commit-craft [COMMAND] [OPTIONS]

COMMANDS:
  commit      Generate a conventional commit message
  pr          Generate a PR description
  changelog   Generate a changelog entry
  --help      Show this help message

EXAMPLES:
  commit-craft commit
  commit-craft pr
  commit-craft changelog

DESCRIPTION:
  Analyzes staged git changes and generates structured messages following
  the Conventional Commits specification.

EOF
  exit 0
}

check_staged_changes() {
  if ! git diff --cached --quiet; then
    return 0
  else
    echo "Error: No staged changes found. Stage your changes with 'git add'." >&2
    exit 1
  fi
}

generate_commit() {
  check_staged_changes
  local diff=$(git diff --cached)
  local summary=$(git diff --cached --stat | tail -1)
  
  echo "Analyzing staged changes..."
  echo ""
  echo "=== CONVENTIONAL COMMIT ==="
  echo ""
  echo "Staged files:"
  git diff --cached --name-only | sed 's/^/  /'
  echo ""
  echo "Summary: $summary"
  echo ""
  echo "Suggested format:"
  echo "  type(scope): subject"
  echo ""
  echo "Types: feat, fix, docs, style, refactor, perf, test, chore"
  echo ""
}

generate_pr() {
  check_staged_changes
  echo "=== PR DESCRIPTION TEMPLATE ==="
  echo ""
  echo "## Changes"
  git diff --cached --stat | sed 's/^/- /'
  echo ""
  echo "## Type of Change"
  echo "- [ ] Bug fix"
  echo "- [ ] New feature"
  echo "- [ ] Breaking change"
  echo "- [ ] Documentation update"
  echo ""
  echo "## Testing"
  echo "- [ ] Unit tests added/updated"
  echo "- [ ] Manual testing completed"
  echo ""
}

generate_changelog() {
  check_staged_changes
  echo "=== CHANGELOG ENTRY ==="
  echo ""
  echo "## [Unreleased]"
  echo ""
  echo "### Added"
  echo "- "
  echo ""
  echo "### Fixed"
  echo "- "
  echo ""
  echo "### Changed"
  git diff --cached --name-only | sed 's/^/- /'
  echo ""
}

[[ $# -eq 0 || "$1" == "--help" ]] && usage

case "$1" in
  commit)
    generate_commit
    ;;
  pr)
    generate_pr
    ;;
  changelog)
    generate_changelog
    ;;
  *)
    echo "Error: Unknown command '$1'" >&2
    usage
    ;;
esac