---
name: post-session-review
description: "Critically review a finished work session: what actually changed, what is missing, ranked next steps, what you would do differently, and bold ideas. Use at the end of a session."
disable-model-invocation: true
---

# Post-session review

The user is closing a work session and wants an honest, critical look back plus a short menu of what to do next. Do not start any of that work.

## Steps

1. **Re-read the evidence, not your memory.** Default to the current session unless the user names another. Gather what actually changed:
   - `git log` / `git diff` since the session started, on every repo touched.
   - PRs, issues, or tickets opened or updated (`gh pr view`, `gh issue view`).
   - Files written outside git, and the conversation itself for the original goal and any promises made.
   If a source is unavailable, say so in one line instead of guessing.

2. **Pin the original goal.** State it in one sentence, in the user's words where possible. Every finding below is measured against it.

3. **Write the review**, in the user's language, with these sections in this order:

   - **What changed**: 3-6 bullets, each naming the commit, PR, or file.
   - **Missing or half-done**: gaps against the goal; untested paths, TODOs, docs not updated, checks not run. Name where.
   - **Next steps**: ranked by value for effort, highest first. Each one a concrete action (file, PR, command), not a theme.
   - **In hindsight**: what you would do differently in approach, design, or process, and why. Be candid about your own mistakes.
   - **Bold ideas**: 2-3 ideas nobody has raised yet that would take the work to the next level. One line each plus why it is worth it.

4. **Ask, then stop.** End by asking which items to do next (refer to them by number). Do not begin any of them in the same reply.

## Style

- Short and actionable. Every bullet specific; drop any bullet you cannot tie to evidence or a concrete action.
- No praise, no recap of the conversation, no padding. An empty section gets "Nothing." rather than filler.
- Number the items across sections so the user can answer "do 2 and 5".
- Severity over completeness: a missing test on the core path outranks a typo.

## Related

- For improving the agent's environment (steering files, checks, tooling) rather than the work itself, use `retro`.
- To pass unfinished work to another agent, use `handoff`.
