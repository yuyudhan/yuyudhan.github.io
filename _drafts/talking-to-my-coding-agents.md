---
layout: post
title: "Talking to my coding agents: speech-to-text plugins for omp and OpenCode"
date: 2026-11-11 10:10:00 +0530
description: "Two small push-to-talk plugins that record your mic, transcribe it with Whisper, clean the text up with a fast LLM that knows coding words, and drop it into the agent's prompt."
tags: [speech-to-text, ai-agents, omp, opencode, open-source]
project: speech-to-text
repo: https://github.com/yuyudhan/omp-speech-to-text
---

These are two small plugins that do the same thing in two coding-agent terminals. Press a key, speak your prompt, press it again: the recording is transcribed with Whisper, cleaned up by a fast LLM that fixes punctuation and coding words, and dropped into the prompt. [omp-speech-to-text](https://github.com/yuyudhan/omp-speech-to-text) is for [oh-my-pi (omp)](https://github.com/can1357/oh-my-pi); [opencode-speech-to-text](https://github.com/yuyudhan/opencode-speech-to-text) is for [OpenCode](https://opencode.ai).

Both need `sox` for recording and, for the cloud providers, a Groq or OpenAI key in your environment:

```sh
brew install sox
export GROQ_API_KEY=...
```

For omp, clone the plugin and link it:

```sh
git clone https://github.com/yuyudhan/omp-speech-to-text.git
omp plugin link "$PWD/omp-speech-to-text"
```

For OpenCode, clone it, `npm link` it, and list it under `plugin` in `~/.config/opencode/opencode.json`, as the [README](https://github.com/yuyudhan/opencode-speech-to-text#install) shows.

## The itch

Prompts to coding agents are long. A good one explains what is wrong, what you tried, and what you do not want touched, and that is a paragraph of typing for every request. Saying it takes a fraction of the time. What stopped me from dictating was the output: a plain transcript of a technical sentence is full of "Jason" for JSON, "cash" for cache and "pie" for pi, with no punctuation.

So each plugin is two stages: Whisper for the words, then a small LLM pass whose only job is to fix punctuation, capitalisation and those homophones, and to spell your own vocabulary correctly.

## What it looks like

In omp, **Ctrl+'** starts recording and stops it again (the same as `/voice`). In OpenCode the default keybind is **Ctrl+R** (`/voice-record`). Both have the same small set of commands to switch the provider, the Whisper model, the microphone and the language, and to cancel a recording:

| omp | OpenCode | What it does |
|-----|----------|--------------|
| `/voice` | `/voice-record` | start or stop recording |
| `/voice-cancel` | `/voice-cancel` | discard the current recording |
| `/voice-provider` | `/voice-provider` | switch the transcription provider |
| `/voice-model` | `/voice-model` | pick the Whisper model |
| `/voice-mic` | `/voice-mic` | pick the audio input |
| `/voice-language` | `/voice-language` | set a language or auto-detect |

Your choices of provider, model, microphone and language are saved and survive restarts.

One terminal detail is worth knowing, and it is in the omp README: WezTerm sends no distinct sequence for Ctrl plus a symbol unless you bind it, so Ctrl+' just types an apostrophe. One line in `wezterm.lua` fixes it:

```lua
{ key = "'", mods = "CTRL", action = wezterm.action.SendString("\x1b[39;5u") },
```

## Under the hood

The pipeline is deliberately plain. `sox` records 16 kHz mono WAV. A second key press stops it (OpenCode can also stop on a pause in auto mode). Cloud providers get the file posted to their `/audio/transcriptions` endpoint; your custom terms go along as Whisper's biasing prompt, and the language when you set one. Then the raw text goes to an OpenAI-compatible chat model for the clean-up, and the result is put into the prompt.

The two plugins differ in their choices:

- **omp-speech-to-text** (TypeScript) supports Groq, OpenAI and custom endpoints, and cleans up with Groq's `llama-3.3-70b-versatile`, falling back to `llama-3.1-8b-instant` if that fails.
- **opencode-speech-to-text** (JavaScript) adds a fully offline provider through [whisper.cpp](https://github.com/ggerganov/whisper.cpp), makes every step configurable (the clean-up endpoint, model, prompt and key, your custom terms, auto-stop on silence), and can pass the active session's title to the clean-up, so "that function" has some context.

## Honest trade-offs

- With a cloud provider your audio is uploaded. If that matters, use the OpenCode plugin's `local` provider with whisper.cpp.
- Cloud APIs reject recordings over 25 MB, so very long monologues fail.
- On macOS the first recording may be silent until your terminal is allowed to use the microphone.
- In OpenCode the appended text is correct, but the input box may not grow to show it. That is an [OpenCode issue](https://github.com/sst/opencode/issues/5664), cosmetic only.

For dictation everywhere, not just in an agent's prompt, there is [Simple Voice](https://github.com/yuyudhan/simple-voice), which runs its models on-device. These plugins are for when you want the text to go straight into the agent's prompt and nowhere else.

## Links

- omp plugin: [github.com/yuyudhan/omp-speech-to-text](https://github.com/yuyudhan/omp-speech-to-text)
- OpenCode plugin: [github.com/yuyudhan/opencode-speech-to-text](https://github.com/yuyudhan/opencode-speech-to-text)

Both are MIT licensed.
