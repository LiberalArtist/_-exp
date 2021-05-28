#lang info

(define pkg-name "_-exp")
(define collection "_-exp")
(define pkg-desc
  "Like #lang at-exp, but with configuable command character")
(define version "0.1")
(define pkg-authors '(philip))

;; Documentation
(define scribblings
  '(("scribblings/_-exp.scrbl" ())))

;; Dependencies
(define deps
  '(["base" #:version "6.12"]
    "at-exp-lib"
    "syntax-color-lib"
    ))
(define build-deps
  '("scribble-lib"
    "racket-doc"
    "scribble-doc"
    "adjutor"
    ))

