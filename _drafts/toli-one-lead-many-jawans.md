---
layout: post
title: "toli: one lead to talk to, a crew of agents that do the work"
date: 2026-11-11 10:40:00 +0530
description: "Why I stopped babysitting one coding agent at a time and built toli: a lead session that only listens and dispatches, background jawans that do the work, and proof before anything is called done."
tags: [toli, ai-agents, developer-tools, open-source]
project: toli
repo: https://github.com/yuyudhan/toli
---

toli turns the coding agent you already use into a small team. You talk to one session, the lead. It never does the work itself, so it is always free to listen: it writes each request down as a task and sends background workers, which toli calls jawans, to do it in parallel while you keep talking. Nothing is called done until a second jawan has checked the proof.

```sh
curl -fsSL https://raw.githubusercontent.com/yuyudhan/toli/main/install.sh | sh
```

Then open your agent in the toli folder (`omp`, `claude`, `codex`, `cursor-agent`, `grok` or `pi`) and say "set up toli". It runs on macOS, Linux and Windows through WSL2, and needs `git` and [bun](https://bun.sh).

## The itch

My day with coding agents used to look like this: ask for a fix, watch it read files for minutes, think of the next thing, and wait. If I asked for the second thing in the same chat, I either interrupted the first or queued it behind it. So I opened more terminals, and then I was the one keeping track of which terminal was doing what, which one had finished, and which one had quietly claimed a test passed without running it.

What I wanted was not a smarter agent. I wanted the shape of a small team: one person I talk to, who writes things down and hands them out, and people who come back with evidence.

## What using it looks like

You say things in plain words, and they turn into tasks:

- "Fix the login redirect bug in billing-api."
- "Find out why the web-app build got slow. Don't change anything yet."
- "Every weekday at 9 am, summarise yesterday's commits in billing-api."
- "What's waiting on me?"

Each request becomes a task in the same turn, with a shape: **ship** changes code, **scout** investigates and writes a report without touching code. The lead fills in a brief (your words verbatim, a goal with a machine-checkable stop condition, the acceptance lines, the project's notes) and starts a jawan in the background. Then it answers in a line or two and is free again. You can ask for five things in a row and none of them blocks the chat.

When a jawan finishes, its result arrives on its own. On omp an extension pushes it into the session every minute; on Claude Code a prompt hook adds it to your next message; on the other harnesses it shows up in the digest. If a jawan hits a question it cannot answer, the task goes on hold with two to four options and a recommendation, and the lead raises all of those together instead of pinging you one at a time.

The names come from the README: you are the Malik, the lead is the Sardar, one helper is a jawan, a group of jawans sent out together is a toli, and all of them across your machines are the paltan. If that is not your style, `config/persona.json` lets you pick your own names for you, the lead and the jawans.

## The rule that made it work

The one principle in toli's docs is short: the lead never works, jawans do everything, the lead stays available. It does not read code, check proof, commit or write reports, not even "quick" ones. On omp and Claude Code a guard enforces it: the lead may only write toli's own records and may not read project code.

That felt extreme when I wrote it. It turned out to be the whole point. The moment the lead does "just one small thing", it is busy, and you are back to waiting.

## Proof before done

A jawan's result is not the end. For ship work a second, independent jawan checks the first one's evidence against the acceptance lines, re-runs the checks, and only then commits and closes the task, or reports what is missing so the lead can send a fix. Depending on the project's notes, that evidence is test output, logs, a page opened in a headless browser, before and after screenshots, or a test that fails before a fix and passes after.

It is also safe by default. Work lands as a commit and stops there: no push, PR, merge or release without your word for that change. Uncommitted work is never thrown away; no `reset --hard`, no `stash`, no force push over changes the jawan did not make.

## Under the hood

Two choices I like.

**Everything is a plain file.** toli is a folder you open your agent in. Tasks, briefs, reports, decisions, job results and inbox messages are files inside it. `bin/toli digest` reads all of it at the start of every session, so a fresh session knows what is in flight, what is waiting on you, and what each project's branch looks like. There is no server to keep alive.

**One contract, six harnesses.** One `AGENTS.md` and one set of skills and commands serve omp, Claude Code, Codex, Cursor, Grok CLI and pi. `bin/toli harness sync` links them into each harness's own folders. Harnesses with background subagents use their own; the ones whose main turn waits get headless jawans through `bin/toli spawn`.

It also spans machines. Every machine has its own lead, served by a launchd agent, systemd user service or cron line when no terminal is open, and leads hand work to each other with `bin/toli delegate`. Results that cannot be delivered wait in an outbox and are retried every minute, so nothing is lost while a machine is asleep. Heavy builds take turns in a machine's build slots instead of all compiling at once.

## Honest trade-offs

It is opinionated. If you like to sit with one agent and steer every step, the lead's refusal to do work itself will feel like friction. The parallelism also has a cost: several jawans on one project means several sets of changes, and toli's answer (each jawan commits only the paths it changed) works, but you still need to read what lands.

## What's next

Releases come often; v0.4.2 is the latest as I write this. toli checks for a new release every three days, tells you once what changed, and updates only when you say so.

## Links

- Repository: [github.com/yuyudhan/toli](https://github.com/yuyudhan/toli)
- Releases: [github.com/yuyudhan/toli/releases](https://github.com/yuyudhan/toli/releases)
- How it works: [docs/how-it-works.md](https://github.com/yuyudhan/toli/blob/main/docs/how-it-works.md)
- Install and setup: [docs/install.md](https://github.com/yuyudhan/toli/blob/main/docs/install.md), [docs/setup.md](https://github.com/yuyudhan/toli/blob/main/docs/setup.md)
- Harnesses: [docs/harnesses.md](https://github.com/yuyudhan/toli/blob/main/docs/harnesses.md)

toli is MIT licensed and inspired by [firstmate](https://github.com/kunchenguid/firstmate): the idea of a lead that never does the work itself. It is a separate implementation.
