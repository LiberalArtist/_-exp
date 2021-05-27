#lang racket/base

(require _-exp/current-command-char
         (only-in scribble/reader make-at-readtable)
         syntax-color/scribble-lexer
         syntax/readerr
         racket/contract
         racket/match
         syntax/module-reader)

(provide current-command-char
         command-char/c
         illegal-command-char/c
         -read -read-syntax -get-info
         (contract-out
          [current-meta-lang-name-string
           (parameter/c string?)]
          [make-current-command-char-readtable
           (-> readtable?)]
          [cmd-char-read-spec
           (-> input-port? (or/c bytes? #f))]
          ))

(module* reader racket/base
  (require (submod ".."))
  (provide (rename-out
            [-read read]
            [-read-syntax read-syntax]
            [-get-info get-info])))
          
(define (default-read-spec in)
  ;from syntax/module-reader
  (let ([spec (regexp-try-match #px"^[ \t]+(.*?)(?=\\s|$)" in)])
    (and spec (let ([s (cadr spec)])
                (if (equal? s "") #f s)))))

(define (string-first-char str)
  (string-ref str 0))

(define (cmd-char-read-spec in)
  (define-values (line col pos)
    (port-next-location in))
  (match (default-read-spec in)
    [(? bytes?
        (app bytes->string/utf-8
             (regexp #rx"^#:(.)$"
                     (list _ (app string-first-char
                                  cmd-char)))))
     (validate-cmd-char cmd-char in line col pos)
     (current-command-char cmd-char)
     (default-read-spec in)]
    [bs bs]))


(define ((convert-read orig-read/maybe-stx) . args)
  (parameterize
      ([current-readtable (make-current-command-char-readtable)])
    (apply orig-read/maybe-stx args)))


(define (convert-read-syntax orig-read-syntax)
  (define read-syntax
    (convert-read orig-read-syntax))
  (λ args
    (define stx
      (apply read-syntax args))
    (define old-prop
      (syntax-property stx 'module-language))
    (define new-prop
      `#(_-exp/language-info
         get-language-info
         ,(cons (current-command-char)
                old-prop))) 
    (syntax-property stx 'module-language new-prop)))


(define ((convert-get-info orig-get-info) key defval)
  (define (fallback)
    (if orig-get-info
        (orig-get-info key defval)
        defval))
  (define (try-dynamic-require lib export)
    (with-handlers ([exn:missing-module?
                     (λ (x) (fallback))])
      (dynamic-require lib export)))
  (case key
    [(color-lexer)
     (make-scribble-lexer #:command-char (current-command-char))]
    [(drracket:indentation)
     (try-dynamic-require 'scribble/private/indentation 'determine-spaces)]
    [(drracket:keystrokes)
     (try-dynamic-require 'scribble/private/indentation 'keystrokes)]
    [else (fallback)]))



(define (make-current-command-char-readtable)
  (make-at-readtable #:datum-readtable 'dynamic
                     #:command-readtable 'dynamic
                     #:command-char (current-command-char)))

(define current-meta-lang-name-string
  (make-parameter "_-exp"))

(define (validate-cmd-char cmd-char in line col pos)
  (when (illegal-command-char/c cmd-char)
    (define-values (end-line end-col end-pos)
      (port-next-location in))
    (raise-read-error
     (string-append "bad syntax following "
                    (current-meta-lang-name-string)
                    ";\n " (string cmd-char)
                    " is not a legal command-char")
     (object-name in)
     line
     col
     pos
     (and pos
          end-pos
          (- end-pos pos)))))



(define-values (-read -read-syntax -get-info)
  (make-meta-reader
   '_-exp
   "language path"
   #:read-spec cmd-char-read-spec
   lang-reader-module-paths
   convert-read
   convert-read-syntax
   convert-get-info))




