#lang racket/base

(require racket/contract/base
         (only-in _-exp
                  current-command-char
                  command-char/c
                  make-current-command-char-readtable
                  ))

(provide (contract-out
          [make:configure
           (-> (-> readtable?)
               (-> command-char/c any))]
          [configure
           (-> command-char/c any)]
          ))

(define ((make:configure [make-readtable
                          make-current-command-char-readtable])
         cmd-char)
  (parameterize ([current-command-char cmd-char])
    (define old-read (current-read-interaction))
    (define (new-read src in)
      (parameterize ([current-readtable (make-readtable)])
        (old-read src in)))
    (current-read-interaction new-read)))

(define configure
  (make:configure))



