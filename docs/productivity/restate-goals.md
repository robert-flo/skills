## What it does

`restate-goals` stops the [agent](https://www.aihero.dev/ai-coding-dictionary/agent) from rushing into work on a wrong reading of your prompt. Before writing a plan, touching code, or drafting an answer, the agent opens by restating your goal and the problem you are solving in its own words, and stops to ask for your confirmation.

It never begins work in the same reply. Only after you confirm that the restatement is accurate does the [session](https://www.aihero.dev/ai-coding-dictionary/session) continue into its normal flow.

## When to reach for it

Type `/restate-goals`, or the agent reaches for it automatically when you start an open-ended request.

| Situation | What happens |
| --- | --- |
| Starting an open-ended request (a plan, a draft, code work) | The agent restates your goal and problem, then pauses for confirmation |
| Typing `/restate-goals` directly | The agent restates goals for the thread as a whole and waits for your confirmation |
| Answering a closed question (yes/no, widget choice) | Skipped automatically |
| Pure acknowledgement or chit-chat | Skipped automatically |
| You explicitly ask to skip ("just do it", "no restate") | Skipped automatically |

For repairing a message that already failed to land mid-conversation, use [wait-what](https://aihero.dev/skills-wait-what) instead.

## Outcome over command

Restating the literal prompt line by line is a no-op: it wastes tokens telling you what you just typed. `restate-goals` targets the **outcome** you want and the problem that prompted the request, including the implied context the agent inferred.

Naming the inferred context gives you a single surface to catch false assumptions. If a crucial detail is missing, the agent names it as a single working assumption rather than guessing silently.

## The pause is the mechanism

A restatement paired with immediate execution is useless: by the time you read it, the agent has already read files, made edits, or generated speculative plans that pollute the [context window](https://www.aihero.dev/ai-coding-dictionary/context-window).

The pause protects the window. The agent stops and asks one short confirmation question in your language. If the reading is right, you reply with a quick confirmation and work begins. If it is wrong, you correct it in one sentence before any work runs.

## Common questions

**Why can't the agent restate and begin working in parallel?**

Because bad assumptions pollute context. Once an agent starts exploring or generating code on an erroneous premise, clearing the mistake costs far more tokens and time than waiting for a one-word confirmation.

**What happens if the restate is wrong?**

You reply with your correction. The agent incorporates it, restates again in one sentence, and asks for confirmation once more.

**Does it run on every turn?**

No. It fires on open-ended requests that initiate work. Closed answers, option picks, and conversational back-and-forth skip it automatically.

## It's working if

- The first reply opens with two or three plain sentences capturing what you want and why, without labels like "Goal:".
- The reply ends with a short confirmation question and stops without running ahead.
- Correcting a misunderstanding takes one short reply before any files or code are touched.

## Where it fits

`restate-goals` is an upfront guardrail that runs at the very start of open-ended work. Once goals are aligned, work proceeds to [grill-with-docs](https://aihero.dev/skills-grill-with-docs) or the main engineering flow. To repair an unclear message later in a conversation, use [wait-what](https://aihero.dev/skills-wait-what). For the complete map across all skills, consult [ask-matt](https://aihero.dev/skills-ask-matt).
