---
name: restate-goals
description: "Restate the user's goals and the problem they are trying to solve before acting. Use when starting an open-ended request, when asked for a plan or work, or when the user invokes it by name."
---

# Restate goals

Purpose: make sure the agent and the user understand the same thing before any work starts, so the agent does not run off with a wrong reading of the request.

## When it is mandatory
- The user starts a conversation, or starts a new request in an existing one, AND
- the reply is open-ended: an answer, a plan, a draft, a piece of work, advice.

## When to skip
- The agent's own description marks it as exempt from this rule by design (for example, a confrontation guide whose method is to go straight at the issue).
- The user is answering a closed question (a widget pick, an A/B/C choice, a yes/no).
- A pure acknowledgement, thanks, or chit-chat with nothing to act on.
- A scheduled or background wake with nobody who just wrote.
- The user explicitly says to skip it ("no restate", "just do it").

## Steps
1. Before doing anything else, open your first reply with two or three plain sentences in the user's language:
   - what you think their goal is (the outcome they want, not the literal command), and
   - what problem they are trying to solve (why they are asking now, what hurts or is missing).
2. Use your own words. Do not quote or paraphrase their message line by line. Add the implied context you inferred, so they can spot a wrong assumption.
3. If a key part is genuinely unclear, name it in one sentence as your working assumption ("I'm assuming X; tell me if not").
4. Then always stop and ask one short confirmation in the user's language ("¿es eso?", "is that it?"). Do not start any work in the same reply.
   - Only with the user's OK do you continue, and then you follow your own flow as your description defines it (for example, a PM goes to grill-with-docs). Never improvised work such as "I'll read the code and bring you a proposal".
5. If the user corrects the restate, adopt their correction, restate once more in one sentence, and ask again.

## Style
- Short: two or three sentences, not a paragraph of summary.
- No labels such as "Goal:" or "Problem:"; write it as normal sentences.
- Match the agent's own voice and language.
- On a voice-memo reply, the restate is the first spoken sentences of the memo.

## Manual invocation
When the user invokes this skill directly, restate their goals and problem for the current thread as a whole (not just the last message), then ask whether it is right and wait for the OK, as in step 4. This works even in an exempt agent, because the user asked for it.
