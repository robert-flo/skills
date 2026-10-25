# Robert's fork — install, sync, and git workflow

This file holds everything specific to [robert-flo/skills](https://github.com/robert-flo/skills). **[README.md](./README.md)** tracks [mattpocock/skills](https://github.com/mattpocock/skills) so the daily `personal` ← `upstream` rebase does not fight over the same file.

Inspired by [Matt Pocock's post on X](https://x.com/mattpocockuk/status/2105022638368403658?s=20).

> **"My top 3 skill makers:**
> - [@poteto](https://x.com/poteto)
> - [@dexhorthy](https://x.com/dexhorthy)
> - [@emilkowalski](https://x.com/emilkowalski)
>
> *Always learn a ton from reading their skills."*  
> — [@mattpocockuk](https://x.com/mattpocockuk)

---

## Naming convention

My own skills (not from upstream) use the `ro-` prefix, e.g. `ro-restate-goals`, `ro-post-session-review`, `ro-show-me`. Upstream skills keep their names even when I modify them.

---

## Install from this fork

Use the `skills` CLI against `robert-flo/skills` (not `mattpocock/skills`):

### 1. Install interactively / list skills
```bash
npx skills@latest add robert-flo/skills
```

### 2. Install a specific skill
```bash
npx skills@latest add robert-flo/skills/NAME_OF_SKILL
```

### 3. Preview without installing
```bash
npx skills@latest add robert-flo/skills --list
```

### 4. Update installed skills
```bash
npx skills@latest update
npx skills@latest update NAME_OF_SKILL
npx skills@latest update -g   # if installed globally
```

### 5. Keep a local clone in sync (systemd)

`scripts/install-sync.sh` installs a user timer that checks `origin/personal` every 15 minutes. On new commits it fast-forwards the clone, runs `scripts/link-skills.sh`, and drops broken skill symlinks. Dirty clones or other branches are left alone (desktop notification). No network → silent skip; SSH/auth failures fail the unit with a notification.

If a skill name in `~/.claude/skills` or `~/.agents/skills` is not a link into this clone (real dir, file, or Omarchy symlink elsewhere), the timer does not relink: it still fast-forwards, logs conflicts, notifies, and fails until you move those entries.

```bash
scripts/install-sync.sh
curl -fsSL https://raw.githubusercontent.com/robert-flo/skills/personal/scripts/install-sync.sh | bash
```

Interactive installs ask before `link-skills.sh` replaces conflicting names; use `--yes` / `-y` to skip prompts.

Uninstall (units + `~/.local/state/skills-sync`; keeps clone and symlinks):
```bash
scripts/install-sync.sh --uninstall
```

```bash
journalctl --user -u skills-sync
```

---

## The three skill makers (short)

**[@poteto](https://x.com/poteto) — Lauren Tan** · engineering workflows, code quality, parallel collaboration  
→ https://github.com/cursor/plugins/tree/main/pstack

**[@dexhorthy](https://x.com/dexhorthy) — Dex Horthy** · agent architecture, context engineering  
→ https://github.com/humanlayer/skills

**[@emilkowalski](https://x.com/emilkowalski) — Emil Kowalski** · interface design, animation, interaction detail  
→ https://github.com/emilkowalski/skills

When picking a skill, weigh how long the author has practiced in that domain.

---

## Working on this fork (ADR 0024)

Default branch: **`personal`**. Branch **`upstream`** on `origin` is a fast-forward mirror of `mattpocock/skills` `main` — do not push to it.

```bash
git fetch origin
git checkout personal
git branch --set-upstream-to=origin/personal personal
```

Day-to-day work merges via PR into `personal`. Daily sync: `.github/workflows/sync-personal-fork.yml` → reusable workflow in `robert-flo/fleet`, then `--force-with-lease` on `personal`.

Requires secret **`FORK_SYNC_PAT`** (contents + issues on this repo, can bypass `personal` protection). Without it, pushes from Actions fail.
