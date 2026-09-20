# Agent Maintenance Guide

## Scope

This repository contains the user's Neovim configuration. Keep changes focused on
the configuration and its documented behavior.

## Plugin Safety Rule

- For normal maintenance, bug fixes, and configuration requests, modify only this
  repository's configuration files.
- Do not directly edit Neovim plugin source code under `nvim-data/lazy/`.
- Do not modify plugin files merely to work around a plugin bug. Prefer a
  configuration-level workaround, an autocmd, a keymap, a plugin option, or an
  upstream update/report.
- Editing plugin source is allowed only when the user explicitly requests it in
  the current task. Confirm the target plugin and the intended files before doing
  so.
- Adding, removing, disabling, updating, or replacing plugin declarations in this
  repository's configuration is allowed when it is part of the requested change.

## Working Rules

- Inspect the existing configuration and plugin setup before making changes.
- Preserve the repository's existing AstroNvim, lazy.nvim, Lua, and formatting
  conventions.
- Keep changes minimal and avoid unrelated refactors.
- Never revert or overwrite user changes that are unrelated to the current task.
- Use `apply_patch` for manual edits.
- Run a relevant Lua/configuration check after changes when possible.
- Before committing, inspect `git status`, the staged diff, and the recent commit
  style. Generate the commit message from the actual repository changes while
  matching the recent commit style; do not use unrelated generic messages. Stage
  and commit only files relevant to the requested change.

## Documentation Sync

- `README.md` documents user-facing behavior: keymaps, features, and external
  tool requirements.
- When a change adds, removes, or alters user-facing behavior (keymaps, default
  actions, window behaviors, workflows), update `README.md` in the same task,
  and mention the doc update in the task summary.
- Behavior intentionally disabled (e.g. an inert key) is also worth documenting
  when a user could plausibly expect the default behavior.
- README conventions: section headings in English (for searchability), body
  text in Chinese. Keep existing list formatting and grouping.
- Internal-only refactors and invisible fixes do not require doc updates.

## Verification

For configuration-only changes, at minimum check Lua syntax with a headless
Neovim invocation when available. Report any checks that could not be run.
