# _-exp #

Copyright © 2017–present Philip McGrath

The `_-exp` Racket language is a metalanguage similar to `#lang at-exp`,
in that it adds support for the @-reader to some base language.

However, rather than using @ as the command character, `_-exp` allows
the programmer to specify one on a per-module basis using an optional keyword.

```
#lang _-exp maybe-cmd-char-keyword language-path
body ...
```

## License ##

This package is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but **without any waranty;** without even the implied warranty of
**merchantability** or **fitness for a particular purpose.**
See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this package. If not, see <http://www.gnu.org/licenses/>.
