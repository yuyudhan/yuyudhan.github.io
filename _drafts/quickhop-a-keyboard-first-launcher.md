---
layout: post
title: "quickhop: press a key, type a few letters, be there"
date: 2026-11-11 10:30:00 +0530
description: "A fast, open-source, keyboard-first launcher for macOS and Linux in Rust: apps, files, calculations, clipboard history, snippets, and your Raycast script commands unchanged."
tags: [quickhop, rust, launcher, macos, linux, open-source]
project: quickhop
repo: https://github.com/yuyudhan/quickhop
---

quickhop is a keyboard-first launcher for macOS and Linux, written in Rust. Apps, files, calculations and unit conversions, clipboard history, snippets and scripts, all from one place. It is a free alternative to Raycast, and it runs your Raycast script commands unchanged.

```sh
(d="$(mktemp -d)" && trap 'rm -rf "$d"' EXIT INT TERM && u=https://github.com/yuyudhan/quickhop/releases/latest/download/install.sh && { c="$(curl -sSL --retry 3 --retry-all-errors -w '%{http_code}' -o "$d/install.sh" "$u" 2>"$d/err")" && [ "$c" = 200 ] || { [ "$c" = 404 ] && echo "quickhop: release not found: $u" >&2 || echo "quickhop: could not download $u (HTTP ${c:-000}, check the network): $(tail -n 1 "$d/err")" >&2; exit 1; }; } && bash "$d/install.sh")
quickhop doctor
quickhop autostart on
```

The first line installs the prebuilt release, in bash or zsh, for macOS (one universal build for Apple silicon and Intel) and Linux on x86_64 or aarch64 with glibc 2.31 or later. It checks every download's SHA-256 and installs into `~/.local/bin` without sudo, plus `quickhop.app` on macOS. The other two check the setup and start the background daemon now and at every login. The [quickhop page]({{ '/quickhop/' | relative_url }}) on this site has the install too.

## The itch

I have a folder of small scripts that I have carried around for years: open this project, convert that timestamp, paste the standard reply. Raycast made them pleasant on the Mac, with its script command format: a shell script with a few `@raycast.*` comments becomes a command with a title, an icon and arguments. But Raycast is macOS only, its settings live in the app, and my scripts did nothing for me on Linux.

So the requirement was simple to say: the same launcher on both machines, settings in plain TOML I can keep in git, no account, and my existing Raycast scripts running without edits.

## What it looks like

<video src="{{ '/assets/img/posts/quickhop/quickhop-cli.mp4' | relative_url }}" width="880" height="423" autoplay loop muted playsinline aria-label="quickhop in a terminal: converting 5 km to miles, finding Lock Screen, a GitHub quicklink, running a script command, listing clipboard history and expanding a snippet"></video>

Everything works from the command line on both systems:

```sh
quickhop query 5 km to miles               # calculator and units
quickhop query lock screen                 # apps, system commands, emoji, files, ...
quickhop run hello Ada                     # run a Raycast script command
quickhop clipboard list                    # clipboard history, newest first
quickhop launch snippets:reply --arg Ada   # expand a snippet
```

Every result line ends with its id, such as `[system:lock]`. `quickhop launch <id>` runs it, and `--paste` sends a text result straight into the focused app.

On macOS the daemon also shows the launcher window when you press `Alt+Shift+Space` or run `quickhop toggle`. I picked that hotkey on purpose, so it sits next to Raycast's and Alfred's `Alt+Space`, Spotlight and nomouse instead of fighting them.

A Raycast script command is just an executable with comments. Drop it in `~/.config/quickhop/scripts`:

```bash
#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Hello
# @raycast.mode compact
# @raycast.argument1 { "type": "text", "placeholder": "Name", "optional": true }

echo "Hello, ${1:-world}!"
```

`quickhop run hello Ada` prints `Hello, Ada!`. Every field Raycast documents is supported, including all four modes and up to three text, password or dropdown arguments.

Configuration is optional plain text in the same place on macOS and Linux:

```toml
# ~/.config/quickhop/config.toml
max_results = 8

[files]
roots = ["~/code", "~/Documents"]   # what the file index covers

[[quicklinks]]
name = "GitHub search"
url = "https://github.com/search?q={query}"
alias = "gh"                        # `gh tokio` searches GitHub
```

## Under the hood

**Ranking that learns.** Matching uses the nucleo fuzzy matcher, and ranking is frecency per query prefix and result, with a half-life of 7 days, stored in SQLite. If you always pick the same app after typing `te`, it moves up for `te`, and the habit fades if you stop.

**A daemon that is small and boring.** `quickhop daemon` takes an exclusive lock on a lock file, so a second one exits with "already running (pid N)", and the kernel drops the lock if a daemon dies. It listens on a Unix socket where each request is one JSON line each way. It runs the clipboard watcher and keeps the file index current: on Linux, and as a fallback to Spotlight on macOS, that index is a parallel walk plus a file watcher feeding an SQLite FTS5 trigram index.

Everything below the window is toolkit-free and runs headless, so it is tested on every OS in CI. As in nomouse, `unsafe` is only allowed in the two platform crates, and every unsafe block there has to be documented.

## Honest trade-offs

- The launcher window exists on macOS only for now. On Linux everything works from the command line, and the window is being built.
- Clipboard history works on X11 and on Wayland compositors with the data-control protocol (wlroots, KDE, COSMIC). Pasting into the focused app works on macOS and X11; elsewhere quickhop copies and tells you why it did not paste.
- Extensions and AI are designed (JSON-RPC over stdio in any language, and local models through Ollama by default) but not built yet.

## What's next

v0.1.0, the first release, came out on 11 November 2026. The Linux launcher window is next on the [plan](https://github.com/yuyudhan/quickhop/blob/main/docs/plan.md), then extensions.

## Links

- Repository: [github.com/yuyudhan/quickhop](https://github.com/yuyudhan/quickhop)
- Releases: [github.com/yuyudhan/quickhop/releases](https://github.com/yuyudhan/quickhop/releases)
- Docs: [usage](https://github.com/yuyudhan/quickhop/blob/main/docs/usage.md), [script commands](https://github.com/yuyudhan/quickhop/blob/main/docs/script-commands.md), [configuration](https://github.com/yuyudhan/quickhop/blob/main/docs/configuration.md), [all 95 Raycast features and their status](https://github.com/yuyudhan/quickhop/blob/main/docs/features.md)
- On this site: [quickhop]({{ '/quickhop/' | relative_url }})

quickhop is MIT or Apache-2.0, with no account and no telemetry.
