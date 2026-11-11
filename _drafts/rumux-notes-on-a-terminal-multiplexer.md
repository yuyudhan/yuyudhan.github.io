---
layout: post
title: "rumux: early notes on a tmux-like multiplexer in Rust"
date: 2026-11-11 10:05:00 +0530
description: "The design of rumux so far: a background server that owns the terminals, a thin client that draws them, and a small binary protocol between the two. Early, and not usable yet."
tags: [rumux, rust, terminal, tmux]
project: rumux
repo: https://github.com/yuyudhan/rumux
---

rumux is a tmux-like terminal multiplexer I have started in Rust. A background server owns the shells and sessions; a thin client draws them in your terminal and sends your keys back; the two talk over a local Unix socket. This post is about the design, because that is what exists so far: there is nothing to install yet.

## Why write one at all

tmux works, and it sits under almost everything I do in a terminal. But it is the one piece of that setup I treat as a black box. When a key chord does not get through (getting Ctrl+' from WezTerm through tmux to a coding agent took a WezTerm key binding plus tmux's extended-keys settings), I end up reading man pages instead of code I could change. rumux is partly a tool and partly a way to understand that layer properly.

## The shape of it

The repository is one Rust crate built as a library and a binary. The command line is small, with [clap](https://crates.io/crates/clap):

```sh
rumux              # attach to the "default" session
rumux new <name>   # create a named session
rumux ls           # list sessions
rumux kill-server  # stop the server
```

There is also a hidden `server` command. The first client that finds no server running starts itself again as `rumux server`, detached from the terminal, so the sessions survive the client closing. That is how tmux feels to use, and it is the part I wanted to get right first.

## The protocol

The part that is written in full is the wire protocol between client and server, in `src/protocol.rs`. Messages are Rust enums serialised with bincode, framed with a 4-byte big-endian length prefix by tokio's `LengthDelimitedCodec`, with a 64 MiB cap per frame.

The client sends very little: attach to a session with a terminal size, raw key bytes for the active pane, a resize, a detach, or a command after the `Ctrl-b` prefix (split horizontally or vertically, new, next and previous window, move focus in four directions, close a pane, kill a session, list sessions).

The server sends back whole frames of the visible panes, the status bar's data (the session name and each window's id, title and whether it is active), the session list, and a goodbye. Sending full frames is the simple choice to start with.

## The stack

- [tokio](https://crates.io/crates/tokio) drives both sides: PTY input and output and the socket loop on the server, the event loop on the client.
- [portable-pty](https://crates.io/crates/portable-pty), from wezterm, allocates the PTYs.
- [alacritty_terminal](https://crates.io/crates/alacritty_terminal) does the terminal emulation on the server, so each pane's screen state lives there and a client can attach and get a full picture at once.
- [ratatui](https://crates.io/crates/ratatui) and [crossterm](https://crates.io/crates/crossterm) draw the client.
- [tracing](https://crates.io/crates/tracing) logs to a file through a non-blocking appender, because a detached server has no terminal to print to.

## Where it stands

Honestly: early. The repository has the protocol, the command line and the plan in [docs/tech-stack.md](https://github.com/yuyudhan/rumux/blob/main/docs/tech-stack.md). The server and client modules are not in it yet, so it does not build. What comes next is the server: owning the PTYs, keeping each pane's state, and answering an attach with a first frame. When it can do that and survive a detach, it gets a real post.

## Links

- Repository: [github.com/yuyudhan/rumux](https://github.com/yuyudhan/rumux)
- Tech stack and design: [docs/tech-stack.md](https://github.com/yuyudhan/rumux/blob/main/docs/tech-stack.md)

rumux is MIT or Apache-2.0.
