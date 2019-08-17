#lang info

(define pkg-name "_-exp")
(define collection "_-exp")
(define pkg-desc
  "A metalanguage similar to #lang at-exp, but the command character is configuable")
(define version "0.1")
(define pkg-authors '(philip))


(define deps '(("base" #:version "6.12")
               "rackunit-lib"
               "at-exp-lib"
               "syntax-color-lib"
               ))
(define build-deps '("scribble-lib"
                     "racket-doc"
                     "scribble-doc"
                     "web-server-doc"
                     "adjutor"
                     ))
(define scribblings '(("scribblings/_-exp.scrbl" ())))
