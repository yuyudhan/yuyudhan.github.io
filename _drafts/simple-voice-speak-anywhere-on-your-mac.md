---
layout: post
title: "Simple Voice: speak anywhere, clean text lands where you type"
date: 2026-11-11 10:25:00 +0530
description: "Hold fn, speak, let go: Simple Voice turns what you said into clean, well-formatted text and pastes it into whatever app you are typing in. Local models by default, no account, no telemetry."
tags: [simple-voice, speech-to-text, macos, linux, rust, tauri, open-source]
project: simple-voice
repo: https://github.com/yuyudhan/simple-voice
---

Simple Voice is dictation for your whole Mac. Hold **fn**, speak, let go, and clean, well-formatted text is pasted wherever your cursor is: Mail, chat, your editor, a terminal. Fillers and false starts are dropped, lists get laid out, and by default it all runs on your Mac with no account and no telemetry. It also runs on Debian and Ubuntu.

```sh
curl -fsSL https://github.com/yuyudhan/simple-voice/releases/latest/download/install.sh | bash
```

That needs an Apple Silicon Mac on macOS 14 or later, or Debian/Ubuntu on x86-64. The script checks the download's SHA-256 and the app's code signature before it replaces `~/Applications/Simple Voice.app`, and needs no administrator password. Then open Simple Voice and grant Microphone and Accessibility.

## The itch

I talk faster than I type, and most of what I type in a day is not code. It is messages, issue comments, long prompts to coding agents. Dictation existed, but what came out was a transcript: every "um", every "no wait, Thursday", no punctuation worth keeping. I would spend as long fixing the text as I would have spent typing it.

The other half of the itch was privacy. The good transcription services wanted my audio on their servers. I wanted something I could leave on all day without thinking about where my voice was going.

## What it looks like

<video src="{{ '/assets/img/posts/simple-voice/demo.mp4' | relative_url }}" width="1440" height="810" autoplay loop muted playsinline aria-label="Holding fn while saying a short greeting that changes its mind (the launch is on friday, no wait, thursday), then the cleaned-up email pasted into Mail"></video>

That is the whole loop: hold fn, say a sentence that changes its mind halfway, and what lands in Mail is the sentence you meant. If you prefer a toggle, **Control+/** starts and stops a recording. Both shortcuts can be changed.

The other half is editing by voice. Select text in any app, press **Option+/**, say how to change it ("make this more formal", "turn this into bullets", "fix the typos"), and press **Option+/** again. The rewrite replaces the selection, and Cmd+Z undoes it.

<video src="{{ '/assets/img/posts/simple-voice/edit-by-voice.mp4' | relative_url }}" width="1440" height="810" autoplay loop muted playsinline preload="metadata" aria-label="Selecting a note, pressing Option+/ and saying make this more formal, then the note rewritten in place"></video>

Around that there is the rest of an app you live with:

- **History** of every dictation, with the time, the app it went to and the text, to search, copy or retry.
- **Dictionary** for names, jargon and `heard -> written` rules, so your words are spelled your way.
- **Style** per app or kind of app: Formal in Mail, Casual in chat.
- **Snippets** you trigger by voice.
- **Meetings**: record a meeting, and optionally what your Mac plays, and get a timestamped transcript split by speaker, a summary with action items, and answers grounded in the transcript, all on-device.

## Under the hood

**Local first, with a choice of models.** Speech to text runs on-device with Parakeet TDT v3 (25 European languages), Parakeet TDT v2 and Flash Dictation for English, a Hinglish Whisper for Hindi and Hinglish, Whisper Turbo for 99 languages, or Apple Speech. Smart Select picks the model from the languages you speak. Clean-up uses Apple Intelligence or a downloaded Qwen3 4B model through llama.cpp. Each model is a one-time download, from 22 MB to 3.1 GB. If you want Groq's hosted Whisper or chat models, you add your own Groq key, which is kept in the macOS Keychain, and Settings says plainly what is sent. When Groq fails or is slow, the on-device choice does the job instead. If clean-up fails, the plain transcript is pasted, so nothing you said is lost.

**Rust with no `unsafe`, and a Swift helper for everything else.** The app is Tauri 2. The Rust core owns the database, audio capture, the dictation pipeline and meetings, and forbids `unsafe` code. Everything that needs Apple frameworks or native inference lives in a separate Swift helper: the Parakeet and Whisper models on Core ML, Apple Speech, the local LLM, speaker diarization, system-audio capture, the synthetic Cmd+V. The helper is started once and kept resident so the models stay loaded, and it is restarted with a back-off if it exits. On Linux the same app uses a different helper, with Parakeet on sherpa-onnx or Whisper on whisper.cpp.

## Honest trade-offs

- Linux gets less. Hinglish Whisper, Apple Speech, Apple Intelligence and the local language model are macOS only, so formatting on Linux is deterministic by default or Groq. Meetings record only your microphone, with no speaker diarization. The floating pill and the fn key are macOS only too; the tray icon starts and stops dictation instead.
- Releases are signed with the project's own certificate, so macOS keeps the permissions across upgrades, but they are not notarized by Apple yet. The install script clears the download quarantine so macOS opens the app.

## What's next

v0.4.0 is the latest release. It added a banner for every problem that stops or degrades dictation (no microphone, a muted or busy one, a missing permission, a stopped engine, a refused Groq key, a shortcut taken by another app), each in plain words with a button for the fix. Before that, a Mac mini without a microphone just waited silently when you dictated. Now it says why.

## Links

- Repository: [github.com/yuyudhan/simple-voice](https://github.com/yuyudhan/simple-voice)
- Releases: [github.com/yuyudhan/simple-voice/releases](https://github.com/yuyudhan/simple-voice/releases)
- Docs: [getting started](https://github.com/yuyudhan/simple-voice/blob/main/docs/getting-started.md), [all features](https://github.com/yuyudhan/simple-voice/blob/main/docs/features.md), [privacy and your data](https://github.com/yuyudhan/simple-voice/blob/main/docs/privacy.md), [Simple Voice on Linux](https://github.com/yuyudhan/simple-voice/blob/main/docs/linux.md), [troubleshooting](https://github.com/yuyudhan/simple-voice/blob/main/docs/troubleshooting.md)

Everything Simple Voice keeps, from settings and history to downloaded models, lives in `~/.simplevoice` on your Mac. It is MIT licensed.
