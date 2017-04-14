_-exp
=====
The _-exp language is a metalanguage similar to #lang at-exp, in that it adds support for the @-reader to some base language.

However, rather than using @ as the command character, _-exp alows the programmer to specify one on a per-module basis using an optional keyword.

```
#lang _-exp maybe-cmd-char-keyword modudule-path
body ...
```
