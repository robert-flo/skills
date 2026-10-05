# Custom Agent Skills

This repository is a custom fork and curated collection of agent skills inspired by [Matt Pocock's post on X](https://x.com/mattpocockuk/status/2105022638368403658?s=20).

> **"My top 3 skill makers:**
> - [@poteto](https://x.com/poteto)
> - [@dexhorthy](https://x.com/dexhorthy)
> - [@emilkowalski](https://x.com/emilkowalski)
>
> *Always learn a ton from reading their skills."*  
> — [@mattpocockuk](https://x.com/mattpocockuk)

---

## 🚀 How to Install Skills from this Repository

You can install skills directly from this fork using the `skills` CLI:

### 1. Install interactively / List all available skills
```bash
npx skills@latest add robert-flo/skills
```

### 2. Install a specific skill
```bash
npx skills@latest add robert-flo/skills/NAME_OF_SKILL
```

### 3. Preview available skills without installing
```bash
npx skills@latest add robert-flo/skills --list
```

---

## 🧠 The three skill makers, in short

Matt Pocock's picks have one thing in common: years of hands-on practice in their field, turned into skills an agent can actually run. Their directions barely overlap.

**[@poteto](https://x.com/poteto) — Lauren Tan** · engineering workflows, code quality, parallel collaboration
React core team, worked on React Compiler; previously Netflix, Meta and Cursor. Her `pstack` is the set of engineering skills she uses daily: get agents to follow a rigorous process, review their own work and verify what they ship, then run tasks in parallel with confidence.
→ https://github.com/cursor/plugins/tree/main/pstack

**[@dexhorthy](https://x.com/dexhorthy) — Dex Horthy** · agent architecture, context engineering, shipping real software
Founder of HumanLayer and author of *12-Factor Agents*, with a background in DevOps, Kubernetes and infrastructure. His work answers one practical question: how do you get LLM-based software good enough for real users? In practice that means managing context and organising research and planning so agents move work forward in large codebases.
→ https://github.com/humanlayer/skills

**[@emilkowalski](https://x.com/emilkowalski) — Emil Kowalski** · interface design, animation, interaction detail
Design Engineer at Linear, previously Vercel; creator of Sonner, Vaul and animations.dev. His skills encode the judgment calls of design engineering: which easing curve, how long an animation should run, where motion is worth adding, and the small details that decide whether an interface feels polished.
→ https://github.com/emilkowalski/skills

**Takeaway:** when picking a skill, look first at what its author has been working on for years. The deeper the experience, the more the judgment baked into the skill is worth borrowing.

---

## Working on this fork

This fork follows ADR 0024: GitHub's default branch is `personal`. `upstream` is a fast-forward mirror of `mattpocock/skills` `main`. Do not push to that upstream.

A fresh clone already checks out `personal` once that default is set. If an existing clone still tracks `main`:

```bash
git fetch origin
git checkout personal
git branch --set-upstream-to=origin/personal personal
```

Day-to-day commits go through PRs into `personal`. The daily sync workflow lives in `.github/workflows/sync-personal-fork.yml`.

That workflow calls the reusable job in `robert-flo/fleet` (public) and then force-with-lease pushes `personal`. GitHub's `GITHUB_TOKEN` cannot push a protected default branch, so this repo needs a secret named `FORK_SYNC_PAT`: a PAT (or fine-grained token) with `contents` and `issues` on `robert-flo/skills`, owned by someone who can bypass the `personal` protection. Put it in Settings → Secrets and variables → Actions. Leave it unset only for dry runs; the reusable then falls back to `GITHUB_TOKEN` and the push to `personal` will fail.
