#lang scribble/manual

@title{@tt{_-exp}: Configurable Scribble-like Syntax}
@author[(author+email @elem{Philip M@superscript{c}Grath}
                      "philip@philipmcgrath.com"
                      #:obfuscate? #t)]
@defmodule[@racketmodfont{_-exp}
           #:module-paths (_-exp)
           #:lang]

@(require adjutor
          (for-label _-exp
                     racket/base
                     ))

@(define _-exp
   ;@racketmodlink[_-exp @racketmodfont["_-exp"]]
   @seclink["top" @racketmodfont["_-exp"]]
   )

The @_-exp language is a metalanguage similar to
@racket[@#,(hash-lang)] @racketmodname[at-exp], in that it adds
support for the
@(seclink "reader"
          #:doc '(lib "scribblings/scribble/scribble.scrbl")
          "@-reader")
to some base language.

However, rather than using @litchar|{@}| as the command character,
@_-exp alows the programmer to specify one on a per-module basis.
The default command character @litchar{ƒ}, i.e. the result of 
@racket[(integer->char 402)]. This is especially convienient when
working with text in which the character @litchar|{@}| appears frequently.

A module using @_-exp takes the following form: 
@(racketgrammar*
  [module (code:line #,(hash-lang) @#,_-exp maybe-cmd-char-kw module-path
                     body ...)]
  [maybe-cmd-char-kw (code:line)
   (code:line cmd-char-keyword)]
  )
where @svar[cmd-char-keyword], if one is given, should be a keyword
consisting of a single character (the desired command character)
after the @litchar{#:}. For example, supplying @racket[#:ƒ]
would be equivalent to ommiting the @svar[cmd-char-keyword].

@(def
   [ƒ @racketparenfont{ƒ}]
   [at @racketparenfont|{@}|]
   [at-kw (λ () @elem{@racket[#:@] })]
   [open-sqr @racketparenfont["["]]
   [close-sqr @racketparenfont["]"]]
   [open-curl @racketparenfont["{"]]
   [close-curl @racketparenfont["}"]]
   [pipe @racketparenfont["|"]]
   [goodnight @racketidfont{goodnight}]
   [(example-mod [cmd-char ƒ] [kw (λ () @elem{})])
    @racketmod[
 @#,_-exp #,(kw)@#,racketmodname[racket/base]

 (define (#,goodnight who)
   @#,(elem cmd-char @racket[displayln] open-sqr cmd-char @racket[string-append] open-curl @racketvalfont{Goodnight, my } cmd-char pipe @racket[who] pipe @racketvalfont{.} close-curl close-sqr))

 (#,goodnight "someone")
 
 @#,(elem cmd-char goodnight open-curl @racketvalfont{love} close-curl)
 ]]
   [example-output
    @nested[#:style 'code-inset
            @racketoutput{Goodnight, my someone.@(linebreak)Goodnight, my love.}]]
   )

As an illustration, this module in @_-exp @(example-mod)
displays the following output: @example-output

It could be re-written to use @litchar|{@}| as the command character
by using a @svar[cmd-char-keyword], like this: @(example-mod at at-kw)