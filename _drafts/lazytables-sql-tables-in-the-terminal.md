---
layout: post
title: "LazyTables: browsing SQL tables without leaving the terminal"
date: 2026-11-11 10:20:00 +0530
description: "A terminal SQL viewer and editor with vim-style navigation, a six-pane layout and encrypted saved connections, for PostgreSQL, MySQL, MariaDB and SQLite."
tags: [lazytables, rust, sql, tui, open-source]
project: LazyTables
repo: https://github.com/yuyudhan/LazyTables
---

LazyTables is a terminal SQL viewer and editor with vim-style navigation. It connects to PostgreSQL, MySQL, MariaDB and SQLite, shows your tables in a six-pane layout, and lets you run the query under your cursor. The tagline in the README says it best: because life's too short for clicking around in database GUIs.

```sh
cargo install lazytables
```

Or, with prebuilt binaries, `cargo binstall lazytables`. It needs a terminal with 256 colours, on macOS or Linux.

## The itch

The database GUI was the last mouse-heavy tool in my day. Everything else was in the terminal, and then I would switch to a separate app to look at twenty rows, click through three panels to find the right table, and copy a query back and forth. I wanted a TUI where the common things are one key away and you never lose your place.

## What it looks like

```sh
lazytables
```

The first time:

1. Press `a` to add a connection.
2. Press `Enter` to connect.
3. Press `2` to browse tables.
4. Press `?` for help.

The six panes are Connections, Tables, Details, Query Results, the SQL Editor and your SQL Files. The number keys `1` to `6` jump straight to a pane, and `Tab` and `Shift+Tab` cycle through them. Inside a table it is the vim keys you already have in your fingers: `h` `j` `k` `l` to move between cells, `gg` and `G` for the first and last row, `0` and `$`.

In the editor, `i` enters insert mode, `Ctrl+Enter` runs the SQL at the cursor, `Ctrl+S` saves the query and `Ctrl+N` starts a new timestamped query file. So a scratch query you wrote at 4 pm is still there the next morning, as a file.

In the table viewer, `t` toggles between the data and the schema: columns with their primary keys, indexes with type, uniqueness and size, foreign keys with their ON DELETE and ON UPDATE actions, constraints, and table statistics. `x` disconnects, and `Ctrl+C` aborts a connection test that is hanging.

## Under the hood

It is Rust, with the interface built on [Ratatui](https://ratatui.rs). Saved connection credentials are encrypted with AES-GCM, so a connection file on disk is not a list of passwords.

The change I am happiest with in v0.2.3 is not a feature. The event handling had grown large, and the release reorganised about 2,000 lines into one handler module per pane: global keys, connections, tables, query results, the editor, the SQL files browser and overlays. The same release fixed the bug that annoyed me most: the number keys `1` to `6` switched panes even while you were editing a cell, so you could not type a number into a numeric field.

## Honest trade-offs

I took features out. LazyTables used to try to create tables and edit schemas, and v0.2.3 removed that to focus on viewing data and querying it. A TUI that does everything well is a lot of work; one that does the daily reading part well was worth more to me. If you need migrations or schema design, keep your other tool for that.

## What's next

The README lists Oracle, Redis, MongoDB, DB2 and ClickHouse as coming. Nothing more to promise than that yet.

## Links

- Repository: [github.com/yuyudhan/LazyTables](https://github.com/yuyudhan/LazyTables)
- Releases: [github.com/yuyudhan/LazyTables/releases](https://github.com/yuyudhan/LazyTables/releases)
- On crates.io: [lazytables](https://crates.io/crates/lazytables)
- Docs: [installation](https://github.com/yuyudhan/LazyTables/blob/main/docs/user/installation.md), [key bindings](https://github.com/yuyudhan/LazyTables/blob/main/docs/user/key-bindings.md), [configuration](https://github.com/yuyudhan/LazyTables/blob/main/docs/user/configuration.md), [v0.2.3 release notes](https://github.com/yuyudhan/LazyTables/blob/main/docs/release_notes/v0.2.3.md)

LazyTables is under the WTFPL, which is exactly as permissive as it sounds.
