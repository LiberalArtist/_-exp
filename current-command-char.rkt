#lang racket/base

(require racket/contract/base)

(provide command-char/c
         illegal-command-char/c
         (contract-out
          [current-command-char (parameter/c command-char/c)]))

(define illegal-command-char/c
  (or/c #\] #\[))

(define command-char/c
  (and/c char? (not/c illegal-command-char/c)))

(define current-command-char
  (make-parameter #\ƒ))


