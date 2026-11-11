---
layout: post
title: "My Corne keyboard, from ZMK to RMK firmware in Rust"
date: 2026-11-11 10:15:00 +0530
description: "A wireless Corne split on two nice!nano v2 boards, a Miryoku-style 36-key layout with home-row mods, and why I moved its firmware from ZMK to RMK, with one patch of my own."
tags: [keyboard, rmk, zmk, rust, embedded, corne]
project: [yuyudhan-rmk-config, yuyudhan-zmk-config]
---

My keyboard is a Corne: a split board with 42 keys, of which my layout uses 36, on two nice!nano v2 controllers talking over Bluetooth. Its firmware is [RMK](https://github.com/rmk-rs/rmk), written in Rust, and the whole keymap is one TOML file. Before that it ran [ZMK](https://zmk.dev). Both configs are public: [yuyudhan-rmk-config](https://github.com/yuyudhan/yuyudhan-rmk-config) is what runs today, [yuyudhan-zmk-config](https://github.com/yuyudhan/yuyudhan-zmk-config) is where it started.

There is nothing to install here unless you own the same board. If you do:

```sh
just setup            # one-time toolchain
just build both       # rmk-central.uf2 + rmk-peripheral.uf2
just flash left       # double-tap reset first, so it mounts as NICENANO
```

## Why a small keyboard

On a 36-key board there is no number row and no arrow cluster. Everything else lives on layers you reach by holding a thumb key, and that turned out to be the point: my fingers barely move. The layout is Miryoku-style, with QWERTY on the base layer and GACS home-row mods, so A, S, D and F are GUI, Alt, Ctrl and Shift when held, mirrored on the right hand.

![The yuyudhan-1 keymap: QWERTY base with home-row mods and the NAV, NUM, MEDIA, SYM, FUN and MOUSE layers]({{ '/assets/img/posts/keyboard/yuyudhan-1_keymap.svg' | relative_url }})

Each thumb key is a layer when held and a key when tapped:

| Hold | Layer |
|------|-------|
| Space | NAV: vim arrows on H J K L, Home/End, PgUp/PgDn, Caps Word |
| Backspace | NUM: a columnar numpad and brackets on the left hand |
| Escape | MEDIA: volume, brightness, media keys, Bluetooth profiles, lock |
| Enter | SYM: programmer symbols on the left hand |
| Delete | FUN: F1 to F12 and a screenshot key |
| Tab | MOUSE: pointer, scroll wheel, buttons and speed keys |

On the mouse layer a tap moves the pointer 5 units; a hold starts at about 250 per second and ramps to about 750 per second over a second. Holding B, T or G with the left index finger switches to precision, slow or fast travel while you move.

## Why I left ZMK

ZMK is excellent for wireless boards, and my ZMK config worked: two keymap variants, a status screen on the left half, a custom Trishul logo with the battery and connection status on the right. The ZMK config even has a [comparison](https://github.com/yuyudhan/yuyudhan-zmk-config/blob/zmk-for-corne/docs/firmware-comparison.md) of QMK, ZMK and RMK, which at the time concluded that ZMK was the right fit.

The difference is mostly the toolchain. ZMK is C on the Zephyr RTOS, configured through devicetree, Kconfig and `west`, and my build ran in Docker. RMK is Rust with the Embassy async executor, built with Cargo, and its configuration is one `keyboard.toml`, which is a much shorter path from "I want this key to do that" to a firmware file. RMK also has native Vial, so I can remap keys live from [vial.rocks](https://vial.rocks) in a browser, without reflashing.

The trade-off is real and written down in that comparison: RMK is the youngest and smallest of the three, with fewer people looking at it and fewer ready-made definitions.

## Under the hood

**The keymap file is the documentation.** Every setting in `config/keyboard.toml` carries a comment saying what it does and how it changes the feel of typing. The home-row mods use a permissive-hold, unilateral-tap and flow-tap profile with a 200 ms hold; the thumb layer-taps use permissive-hold with no flow-tap. If I forget why a value is what it is, the answer is next to it. `just docs svg` renders that same file into the keymap picture above.

**One patch of my own.** The keyboard has four Bluetooth profiles, one per computer. With two bonded computers near each other, the one that was not active could take the connection. So the firmware builds from [my fork of RMK](https://github.com/yuyudhan/rmk/tree/yuyudhan/per-profile-address), whose one change makes each profile advertise from its own address. A computer only sees the keyboard while its own profile is active. Switching drops the current host and advertises from the new profile's address, fast for 30 seconds and slower after that.

**Builds that are hard to get wrong.** `just build` writes every intermediate file into a gitignored `build/` folder and runs the chain twice: once normally, and once with storage clearing switched on, from a temporary copy of the config so the real file is never edited. Both sets land in one dated `firmware/` folder, and `just flash` picks the newest matching file. For computers that block USB drives, `just flash-serial` sends the same firmware over the bootloader's serial port instead.

## Honest trade-offs

- Any change to the RMK version or its features changes RMK's storage layout, so the first boot after an upgrade erases every Bluetooth bond and every Vial edit. Every computer has to forget the keyboard and pair again.
- The keymap saved by Vial wins over the TOML, so a plain reflash does not apply a TOML edit. You set `clear_layout = true`, flash, set it back, and flash again. Easy to forget.

## What's next

The fork carries one patch, for an [upstream issue](https://github.com/rmk-rs/rmk/issues/901). Until a change like it lands in RMK itself, the build stays pinned to the fork, by commit, so every machine builds the same firmware.

## Links

- RMK config: [github.com/yuyudhan/yuyudhan-rmk-config](https://github.com/yuyudhan/yuyudhan-rmk-config), including [Bluetooth profiles and recovery](https://github.com/yuyudhan/yuyudhan-rmk-config/blob/main/docs/BLUETOOTH.md)
- ZMK config: [github.com/yuyudhan/yuyudhan-zmk-config](https://github.com/yuyudhan/yuyudhan-zmk-config)
- My RMK fork: [github.com/yuyudhan/rmk](https://github.com/yuyudhan/rmk/tree/yuyudhan/per-profile-address)
- RMK itself: [github.com/rmk-rs/rmk](https://github.com/rmk-rs/rmk) and [rmk.rs](https://rmk.rs)
