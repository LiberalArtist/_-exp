#lang info
(define collection "_-exp")
(define deps '("base"
               "rackunit-lib"
               "at-exp-lib"
               "syntax-color-lib"
               ))
(define build-deps '("scribble-lib"
                     "racket-doc"
                     "scribble-doc"
                     "adjutor"
                     ))
(define scribblings '(("scribblings/_-exp.scrbl" ())))
(define pkg-desc
  "A metalanguage similar to #lang at-exp, but the command character is configuable")
(define version "0.0")
(define pkg-authors '(philip))
