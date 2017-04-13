#lang racket/base

(require "current-command-char.rkt"
         racket/match
         racket/contract/base
         )

(provide (contract-out
          [make:get-language-info
           (-> (-> command-char/c
                   (vector/c symbol? symbol? any/c #:flat? #t))
               (-> (cons/c command-char/c any/c)
                   any))]
          [get-language-info
           (-> (cons/c command-char/c any/c)
               any)]
          ))

(define ((make:get-language-info make-config-vec) cmd-char+data)
  (match cmd-char+data
    [(cons cmd-char data)
     (define other-get-info
       (match data
         [(vector mod sym data2)
          ((dynamic-require mod sym) data2)]
         [_ (lambda (key default) default)]))
     (λ (key default)
       (case key
         [(configure-runtime)
          (define config-vec (make-config-vec cmd-char))
          (define other-config (other-get-info key default))
          (cond [(list? other-config) (cons config-vec other-config)]
                [else (list config-vec)])]
         [else (other-get-info key default)]))]))

(define get-language-info
  (make:get-language-info
   (λ (cmd-char)
     (vector '_-exp/runtime-config 'configure cmd-char))))