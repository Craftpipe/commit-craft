---
name: commit-craft
description: "Use this skill when the user wants to generate a commit message, PR description, or changelog from staged or recent git changes. Analyzes diffs and outputs structured, Conventional Commits-compliant messages."
# Built with AI by Craftpipe
---

# commit-craft

## When to use
- User asks to commit changes or write a commit message
- User says "write a commit message" or "commit this"
- User asks to create a PR description or pull request summary
- User asks to generate a changelog
- User asks "what changed" before committing or pushing
- Staged files are present and user wants to push or open a PR

## Instructions
1. Ask the user to paste the output of `git diff --staged` (or `git diff HEAD` if nothing is staged). If the diff is already visible in context, use it directly.
2. Parse the diff and identify: which files changed, what was added, what was removed, and what the net effect is on behavior or functionality.
3. Determine the correct Conventional Commits type from this list based on the changes:
   - `feat` — new feature or capability added
   - `fix` — bug or broken behavior corrected
   - `docs` — documentation only changes
   - `style` — formatting, whitespace, no logic change
   - `refactor` — code restructured, no feature or fix
   - `perf` — performance improvement
   - `test` — tests added or updated
   - `chore` — build process, dependencies, tooling
   - `ci` — CI/CD configuration changes
   - `revert` — reverts a previous commit
4. Identify the scope from the changed file paths or module names. Use the most specific relevant directory or component name. Omit scope only if changes span the entire codebase with no clear focal point.
5. Write the commit subject line using this exact format: `type(scope): short imperative description`. Keep it under 72 characters. Use lowercase. Do not end with a period.
6. Write the commit body if any of these are true: the change is non-obvious, multiple concerns are addressed, or context is needed to understand why the change was made. Separate body from subject with a blank line. Wrap lines at 72 characters.
7. Add a `BREAKING CHANGE:` footer if any public API, interface, or behavior is removed or changed in a non-backward-compatible way.
8. If the user asked for a **PR description**, output the following sections:
   - `## Summary` — 2–4 sentences describing what this PR does and why
   - `## Changes` — bullet list of specific changes grouped by file or feature area
   - `## Testing` — how the changes were or should be verified
   - `## Notes` — any caveats, follow-ups, or reviewer callouts (omit if none)
9. If the user asked for a **changelog entry**, output a single versioned block using Keep a Changelog format: group changes under `Added`, `Changed`, `Fixed`, `Removed`, `Security`, or `Deprecated` as applicable.
10. Output only the requested artifact. Do not add commentary, explanation, or suggestions unless the user explicitly asks.

## Rules
- Output commit messages that follow Conventional Commits spec exactly — no deviation
- Use imperative mood in the subject line ("add", "fix", "remove" — not "added", "fixes", "removed")
- Do not exceed 72 characters on the subject line
- Do not invent changes not present in the diff
- Do not omit breaking changes — always flag them with a `BREAKING CHANGE:` footer
- Do not use vague subjects like "update stuff" or "fix bug" — be specific about what changed
- Do not include file names in the subject line unless the change is scoped to a single config or asset file
- Do not add emoji to commit messages unless the user explicitly requests it
- If the diff is empty or unavailable, ask for it — do not generate a message without source data
- PR descriptions must always include a Summary and Changes section at minimum
- Changelog entries must always be grouped by change type — do not output a flat list

## Examples

**Example 1 — Commit message from a diff**

Input:
```
User: Write a commit message for this diff:

diff --git a/src/auth/token.ts b/src/auth/token.ts
--- a/src/auth/token.ts
+++ b/src/auth/token.ts
@@ -12,6 +12,10 @@ export function generateToken(userId: string): string {
+  if (!userId) {
+    throw new Error('userId is required');
+  }
```

Output:
```
fix(auth): throw error when userId is missing in generateToken

Previously, generateToken would silently produce an invalid token if
userId was falsy. This adds an explicit guard to fail fast and surface
the issue to the caller.
```

---

**Example 2 — PR description from staged changes**

Input:
```
User: Generate a PR description. Here's the diff — added rate limiting middleware to all API routes, updated the README with setup instructions, and bumped the express dependency to 4.19.0.
```

Output:
```
## Summary
This PR introduces rate limiting across all API routes to prevent abuse
and reduce server load. It also updates the README with setup steps for
the new middleware and upgrades express to address a known vulnerability.

## Changes
- `src/middleware/rateLimit.ts` — new rate limiting middleware using a
  sliding window algorithm; default limit set to 100 requests per minute
- `src/app.ts` — applied rate limit middleware globally before route handlers
- `README.md` — added configuration section for rate limiting environment
  variables
- `package.json` — bumped express from 4.18.2 to 4.19.0

## Testing
- Verified rate limit triggers correctly at threshold using manual curl tests
- Existing integration tests pass with middleware applied

## Notes
The rate limit values are configurable via `RATE_LIMIT_MAX` and
`RATE_LIMIT_WINDOW_MS` environment variables. Defaults are conservative
and may need tuning for high-traffic deployments.