---
layout: post
title: "The small stuff: Verhoeff checksums in three languages, geometry helpers and a typing trainer"
date: 2026-11-11 10:00:00 +0530
description: "A round-up of the small libraries and side projects on my GitHub: the Verhoeff checksum in JavaScript, Rust and Go, two geometry modules, a typing practice page, a repository analyzer and a Rust learning notebook."
tags: [libraries, javascript, rust, go, python, open-source]
project: [verhoeff, verhoeff.rs, verhoeff.go, node-coordinate-geometry, geometry, typing-practice, repo_analyzer, learning, yuyudhan-wallpapers]
---

Not everything on my GitHub is an app. A lot of it is small: a function I needed twice, a module I wrote to learn something, a page I made for practice. None of these deserves a post of its own, but together they say a fair amount about what I was learning when. Here they are, with what each one does and how to use it.

## The Verhoeff checksum, three times

The Verhoeff algorithm adds one check digit to a number, and it catches every single-digit error and every swap of two adjacent digits. That is exactly the kind of mistake people make when they type a long number by hand. It is also why I first met it: the last digit of an Aadhaar number, India's 12-digit ID, is a Verhoeff check digit. I have written it three times, in three languages, years apart.

**[verhoeff](https://github.com/yuyudhan/verhoeff)**, the first one, in Node.js. The original code is by Sergey Petushkov (2014); I packaged it with an Aadhaar check on top.

```sh
npm i node-verhoeff --save
```

```js
var verhoeff = require('node-verhoeff');
verhoeff.validateAadhaar('496858245152');          // true
verhoeff.generate([4, 9, 6, 8, 5, 8, 2, 4, 5, 1, 5]); // 2, the check digit
```

**[verhoeff.rs](https://github.com/yuyudhan/verhoeff.rs)**, in Rust, with no dependencies and const lookup tables. It is published as `verhoeff-checksum` (the plain `verhoeff` name on crates.io belongs to someone else), and you import it as `verhoeff`:

```sh
cargo add verhoeff-checksum
```

```rust
use verhoeff::{append_checksum, calculate_checksum, validate, validate_aadhaar};

let checksum = calculate_checksum("12345");   // 1
let with_check = append_checksum("12345");    // "123451"
let ok = validate("123451");                  // true
let aadhaar = validate_aadhaar("123456789010"); // Result<bool, VerhoeffError>
```

`calculate_checksum` and `validate` also have `_result` forms that return an error for bad input instead of a default.

**[verhoeff.go](https://github.com/yuyudhan/verhoeff.go)**, in Go, with functions for strings, `int`, `int64` and slices, generic ones that take any of those, an Aadhaar check, and no dependencies. It is on [pkg.go.dev](https://pkg.go.dev/github.com/yuyudhan/verhoeff.go).

```sh
go get github.com/yuyudhan/verhoeff.go
```

```go
checksum, _ := verhoeff.GenerateFromString("12345")    // 1
valid, _ := verhoeff.ValidateString("123451")          // true
result, _ := verhoeff.AppendChecksumString("12345")    // "123451"
aadhaar, _ := verhoeff.ValidateAadhaar("123456789010")
```

Writing the same small algorithm three times is a good way to feel a language. The JavaScript one takes whatever you hand it. The Rust one makes you decide what a bad input is, and returns it as an error type. The Go one ended up with the most functions, one per input type, with the generic `Generate`, `Validate` and `AppendChecksum` on top.

## Geometry for Node

**[node-coordinate-geometry](https://github.com/yuyudhan/node-coordinate-geometry)** collects 2D coordinate geometry functions for Node and front-end JavaScript: angles, axes, lines, points and polygons. Points are `[x, y]`, line segments are `[[x1, y1], [x2, y2]]`, polygons are lists of points, and angles are in radians throughout.

```sh
npm i node-coordinate-geometry --save
```

```js
var ncg = require('node-coordinate-geometry');
ncg.polygons.area([[0, 0], [4, 0], [4, 3], [0, 3]]);   // 12
ncg.polygons.checkIntersection([[0, 0], [2, 0], [2, 2], [0, 2]],
                               [[1, 1], [3, 1], [3, 3], [1, 3]]); // true
```

**[geometry](https://github.com/yuyudhan/geometry)** is the smaller one before it, with line helpers such as which side of a line a point is on. Use it from the repository: the `geometry` name on npm is someone else's package. Both are tested with mocha.

## Typing Practice

**[typing-practice](https://github.com/yuyudhan/typing-practice)** is a small web page for learning to touch type, and you can [try it right here](https://yuyudhan.github.io/typing-practice/). It shows one character at a time with the finger and Shift key to use, marks your answer right or wrong, and tracks how you do on letters, numbers and special characters, including your median time for each. Sliders set how often each kind of character comes up, so you can drill the ones you are slow at. It is plain HTML and JavaScript; any static server runs it locally.

## Repository Analyzer

**[repo_analyzer](https://github.com/yuyudhan/repo_analyzer)** is a Python command-line tool that points a large language model (Anthropic's, with your own API key) at a codebase, local or a git URL, and writes a technical assessment. It has a developer mode that takes a sentence of human context about what the code is for, and a conversation mode for asking follow-up questions.

```sh
git clone https://github.com/yuyudhan/repo_analyzer.git
cd repo_analyzer && pip install -e .
repo-analyzer check --check-all
repo-analyzer analyze --repo /path/to/repo
```

## Learning, out loud

**[learning](https://github.com/yuyudhan/learning)** is where I put code while I learn something, currently Rust: data types, structs, printing and comments, functions and macros, and a small CLI. The README calls it a digital graveyard of coding experiments and questionable life choices, and that is accurate. It is not a library. It is the notebook.

And because not everything has to be code: **[yuyudhan-wallpapers](https://github.com/yuyudhan/yuyudhan-wallpapers)** is my set of Parshuram wallpapers.

## Links

- All repositories: [github.com/yuyudhan](https://github.com/yuyudhan?tab=repositories)
- On npm: [node-verhoeff](https://www.npmjs.com/package/node-verhoeff), [node-coordinate-geometry](https://www.npmjs.com/package/node-coordinate-geometry)
- On crates.io: [verhoeff-checksum](https://crates.io/crates/verhoeff-checksum)
- On pkg.go.dev: [verhoeff.go](https://pkg.go.dev/github.com/yuyudhan/verhoeff.go)
