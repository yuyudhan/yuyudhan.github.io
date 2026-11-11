---
layout: post
title: "nomouse: click anything on screen without touching the mouse"
date: 2026-11-11 10:35:00 +0530
description: "A free, open-source Homerow alternative for macOS and Linux, written in Rust: press a hotkey, every clickable thing gets a short label, type the label and nomouse clicks it."
tags: [nomouse, rust, macos, linux, keyboard, open-source]
project: nomouse
repo: https://github.com/yuyudhan/nomouse
---

nomouse lets you click anything on screen from the keyboard. Press `ctrl+space`, and every button, link, tab and field in the focused window gets a short yellow label. Type the label and nomouse clicks it. It is a free, open-source alternative to Homerow, for macOS and Linux, written in Rust.

```sh
(d="$(mktemp -d)" && trap 'rm -rf "$d"' EXIT INT TERM && u=https://github.com/yuyudhan/nomouse/releases/latest/download/install.sh && { c="$(curl -sSL --retry 3 --retry-all-errors -w '%{http_code}' -o "$d/install.sh" "$u" 2>"$d/err")" && [ "$c" = 200 ] || { [ "$c" = 404 ] && echo "nomouse: release not found: $u" >&2 || echo "nomouse: could not download $u (HTTP ${c:-000}, check the network): $(tail -n 1 "$d/err")" >&2; exit 1; }; } && bash "$d/install.sh")
```

That is a long line for an install, I know. It downloads `install.sh` into a temporary folder, runs it only after an HTTP 200, checks the SHA-256, and cleans up after itself, without sudo. It covers macOS 11+ (Apple silicon and Intel) and Linux on x86_64 and aarch64, X11 and Wayland. The [nomouse page]({{ '/nomouse/' | relative_url }}) on this site has the install too, and `.deb` packages and the Windows build are in the [install docs](https://github.com/yuyudhan/nomouse/blob/main/docs/install.md).

## The itch

I spend most of the day in a terminal and an editor with vim keys, and the keyboard is where my hands want to be. The mouse trip was always for the same small things: a button in a dialog, a tab in a browser, a checkbox in a settings window. Homerow solves exactly this on macOS, and it is good. But it is paid, closed source, and macOS only, and I also work on Linux. I wanted the same habit on both machines, configured from one text file I could keep in my dotfiles.

## What it looks like

![Continuous mode on macOS Calculator: labels appear on every key; typing four labels presses 7, ×, 6 and =, and the display shows 42]({{ '/assets/img/posts/nomouse/demo-macos.gif' | relative_url }})

That is continuous mode on the macOS Calculator: labels stay up after every click, so four labels type 7 × 6 = and the display shows 42. Here is the whole first use:

1. Start it. On macOS, `open /Applications/nomouse.app`; a Welcome window asks for the Accessibility permission and restarts nomouse once it is allowed. On Linux X11, `nomouse setup` and then pick nomouse in the app launcher. On Wayland, bind the modes in your compositor, for example in Sway: `bindsym Ctrl+space exec nomouse hints`.
2. Press `ctrl+space`. Labels appear in the middle of everything clickable.
3. Type a label, like `dh`. nomouse clicks it. Escape cancels.

There are four modes:

| Hotkey | Mode |
|--------|------|
| `ctrl+space` | hints: label the window, type a label to click |
| `ctrl+shift+space` | continuous: keep labelling after every click |
| `ctrl+alt+space` | scroll: pick a scrollable area, then `h` `j` `k` `l`, `gg` and `G` |
| `ctrl+alt+/` | search: type part of a button's text, Enter clicks the best match |

While labels are up, `1` to `4` hold Shift, Ctrl, Alt or Cmd for the click, so `4` and then a link's label opens it in a new tab on macOS. Backspace undoes a letter. If you are coming from Homerow, `hints.keys = "homerow"` gives you its key bindings.

![The same on Linux: GNOME Calculator on X11 with labels on every button, typing labels to compute 7 × 6 = 42]({{ '/assets/img/posts/nomouse/demo-linux.gif' | relative_url }})

It needs no configuration. When you want some, `nomouse config init` writes `~/.config/nomouse/config.toml` with every default, and a running daemon picks up a saved file within two seconds:

```toml
[hints]
alphabet = "fjdksagh"      # label letters, most comfortable first

[hotkeys]
hints = "cmd+shift+space"

[ignore]
apps = ["com.mitchellh.ghostty", "kitty"]
```

On macOS it lives in the menu bar, with a settings window that edits that same file and keeps your comments. On Linux there is a tray icon and a GTK settings window. `nomouse doctor` checks the permissions, the accessibility API, input and the config, and prints the fix for anything missing.

![The macOS menu bar menu: nomouse on, Accessibility allowed, Pause, each mode with its hotkey, Settings, Run doctor, Start at login, Check for updates, About, Quit]({{ '/assets/img/posts/nomouse/menu-light.png' | relative_url }})

## Under the hood

nomouse does not look at pixels. It reads the accessibility tree, the same structure screen readers use, so it knows what is a button and where it is in any app that exposes one. On Linux that is AT-SPI over D-Bus; on macOS it is the AXUIElement API; on Windows, UI Automation.

The part I enjoyed most is how the code is split. `nomouse-core` holds everything that is not platform specific (the element model, labels, the hint session, config), behind four traits: an element source, an overlay, an input injector and a hotkey source. Each platform crate implements those. `unsafe` is forbidden everywhere except the small `nomouse-sys-*` crates that wrap the OS APIs, and those are audited. The binary depends on exactly one backend for the OS it is built on.

Labels are chosen by a breadth-first expansion of the alphabet, so they are as short as possible and prefix-free: you never have to wait to see whether `d` is a whole label or the start of `dh`.

## Honest trade-offs

- GNOME on Wayland is not supported yet: there is no layer-shell, no virtual pointer and no client hotkeys there. Pick "GNOME on Xorg" at login for now. KDE Wayland works in part.
- Chrome, Slack and VS Code need a nudge to expose their accessibility tree: `macos.enhanced_ui_apps` on macOS, `--force-renderer-accessibility` on Linux.
- Until releases are Developer ID signed, macOS asks for the Accessibility permission again after every update. It is annoying, and the docs explain why.

## What's next

v0.1.9 is the latest release. The next one already has a change I wanted for myself: hint mode scans again at 1 and 3 seconds while you have typed nothing, so a browser page that is still loading gets its labels, and targets that are still there keep theirs.

## Links

- Repository: [github.com/yuyudhan/nomouse](https://github.com/yuyudhan/nomouse)
- Releases: [github.com/yuyudhan/nomouse/releases](https://github.com/yuyudhan/nomouse/releases)
- Docs: [usage](https://github.com/yuyudhan/nomouse/blob/main/docs/usage.md), [configuration](https://github.com/yuyudhan/nomouse/blob/main/docs/configuration.md), [troubleshooting](https://github.com/yuyudhan/nomouse/blob/main/docs/troubleshooting.md), [architecture](https://github.com/yuyudhan/nomouse/blob/main/docs/architecture.md)
- On this site: [nomouse]({{ '/nomouse/' | relative_url }})

nomouse is MIT or Apache-2.0, with no telemetry.
