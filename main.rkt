#lang racket/base

(require "current-command-char.rkt"
         (only-in scribble/reader make-at-readtable)
         syntax/readerr
         racket/contract
         )

(provide current-command-char
         command-char/c
         illegal-command-char/c
         (contract-out
          [current-meta-lang-name-string
           (parameter/c string?)]
          [read-language+cmdchar/values
           ;; also imperatively sets current-command-char
           (-> input-port?
               (values module-path?
                       command-char/c))]
          [make-wrapper2
           (->* []
                [(-> readtable?)]
                (-> input-port?
                    procedure?
                    any/c
                    any/c))]
          [make-current-command-char-readtable
           (-> readtable?)]
          ))

(module* reader syntax/module-reader
  #:language read-language+cmdchar/values 
  #:wrapper2 (make-wrapper2)
  #:info
  (λ (request-symbol default-value default-filter-funct)
    (cond [(equal? 'color-lexer
                   request-symbol)
           (make-scribble-lexer #:command-char language-data)]
          ;TODO: definitions-text-surrogate and drracket:indentation
          [else
           (default-filter-funct request-symbol default-value)]))
  (require syntax-color/scribble-lexer
           (submod ".."))
  #|END module reader|#)


;; based extensively on at-exp

(define (make-current-command-char-readtable)
  #;(-> readtable?)
  (make-at-readtable #:datum-readtable 'dynamic
                     #:command-readtable 'dynamic
                     #:command-char (current-command-char)))
  
(define (convert-read orig-read/maybe-stx [make-readtable make-current-command-char-readtable])
  ;; based on wrap-reader from at-exp
  #;(->* [procedure?]
         [(-> readtable?)]
         procedure?)
  (λ args
    (parameterize
        ([current-readtable (make-readtable)])
      (apply orig-read/maybe-stx args))))

(define (convert-read-syntax orig-read-syntax
                             [make-readtable
                              make-current-command-char-readtable])
  #;(->* [procedure?]
         [(-> readtable?)]
         procedure?)
  (define read-syntax (convert-read orig-read-syntax make-readtable))
  (λ args
    (define stx (apply read-syntax args))
    (define old-prop (syntax-property stx 'module-language))
    (define new-prop `#(_-exp/language-info get-language-info ,(cons (current-command-char)
                                                                     old-prop))) 
    (syntax-property stx 'module-language new-prop)))


;;;;;;;;

(define (make-wrapper2 [make-readtable
                        make-current-command-char-readtable])
  #;(->* [] [(-> readtable?)]
         (-> input-port? procedure? any/c
             any))
  (λ (in rd stx?)
    (cond [stx?
           ((convert-read-syntax rd make-readtable) in)]
          [else
           ((convert-read rd make-readtable) in)])))

(define current-meta-lang-name-string
  (make-parameter "_-exp"))

(define (read-language+cmdchar/values in)
    (define-values (line col pos)
      (port-next-location in))
    (define (validate cmd-char lang)
      (cond
        [(and (module-path? lang)
              (not (illegal-command-char/c cmd-char)))
         (current-command-char cmd-char)
         (values lang
                 cmd-char)]
        [else
         (define-values (end-line end-col end-pos)
           (port-next-location in))
         (raise-read-error (cond
                             [(illegal-command-char/c cmd-char)
                              (string-append "Bad syntax following "
                                             (current-meta-lang-name-string)
                                             ": " (string cmd-char)
                                             " is not a legal command-char")]
                             [else
                              (string-append "Bad syntax following "
                                             (current-meta-lang-name-string)
                                             ":\n"
                                             "    expected: a language path or a command-char "
                                             "keyword followed by a language path\n"
                                             "    given: "
                                             (format "~v" lang))])
                           (object-name in)
                           line
                           col
                           pos
                           (and pos
                                end-pos
                                (- end-pos pos)))]))
    (let ([value (read in)])
      (cond
        [(keyword? value)
         (validate (car (string->list (keyword->string value)))
                   (read in))]
        [else
         (validate (current-command-char)
                   value)])))

