#lang racket/base

(require "current-command-char.rkt"
         (only-in scribble/reader make-at-readtable)
         syntax-color/scribble-lexer
         syntax/readerr
         racket/contract
         )

(module* reader syntax/module-reader
  #:language read-language+cmdchar/values 
  #:wrapper2 (make-wrapper2 #:command-char language-data)
  #:info (make-info-proc language-data)
  (require (submod ".."))
  #|END module reader|#)

(provide current-command-char
         command-char/c
         illegal-command-char/c
         (contract-out
          [current-meta-lang-name-string
           (parameter/c string?)]
          [make-current-command-char-readtable
           (-> readtable?)]
          [make-wrapper2
           (->* []
                [(-> readtable?)
                 #:command-char char?]
                (-> input-port?
                    procedure?
                    any/c
                    any/c))]
          [make-info-proc
           (-> char?
               (-> symbol? any/c (symbol? any/c . -> . any/c)
                   any/c))]
          [read-language+cmdchar/values
           ;; also imperatively sets current-command-char
           (-> input-port?
               (values module-path?
                       command-char/c))]
          ))

;; based extensively on at-exp

(define current-meta-lang-name-string
  (make-parameter "_-exp"))

(define (make-current-command-char-readtable)
  (make-at-readtable #:datum-readtable 'dynamic
                     #:command-readtable 'dynamic
                     #:command-char (current-command-char)))

(define ((make-wrapper2 [make-readtable
                         make-current-command-char-readtable]
                        #:command-char [cmd-char (current-command-char)])
         in rd stx?)
  (parameterize ([current-command-char cmd-char])
    (cond [stx?
           ((convert-read-syntax rd make-readtable) in)]
          [else
           ((convert-read rd make-readtable) in)])))

(define ((make-info-proc cmd-char) request-symbol
                                   default-value
                                   default-filter-funct)
  (case request-symbol
    [(color-lexer)
     (make-scribble-lexer #:command-char cmd-char)]
    [(drracket:indentation)
     ; just using what at-exp does
     (dynamic-require 'scribble/private/indentation 'determine-spaces)]
    ;definitions-text-surrogate ???
    [else
     (default-filter-funct request-symbol default-value)]))

(define (read-language+cmdchar/values in)
  ;; also imperatively sets current-command-char
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
       (read-language-error #:line line
                            #:col col
                            #:pos pos
                            #:in in
                            #:inner-lang lang
                            #:command-char cmd-char)]))
  (let ([value (read in)])
    (cond
      [(keyword? value)
       (validate (car (string->list (keyword->string value)))
                 (read in))]
      [else
       (validate (current-command-char)
                 value)])))

;                                                          
;                                                          
;                                                          
;                                                          
;   ;;              ;;;;                                   
;   ;;                ;;                                   
;   ;; ;      ;;;     ;;    ; ;;      ;;;   ;; ;;;    ;;   
;   ;;; ;   ;;   ;    ;;    ;;  ;   ;;   ;  ;;;     ;;  ;  
;   ;;  ;;  ;    ;    ;;    ;;  ;   ;    ;  ;;       ;     
;   ;;  ;; ;;;;;;;;   ;;    ;;  ;; ;;;;;;;; ;;        ;;   
;   ;;  ;;  ;         ;;    ;;  ;   ;       ;;          ;; 
;   ;;  ;;  ;;   ;     ;    ;;  ;   ;;   ;  ;;      ;   ;  
;   ;;  ;;    ;;;       ;;  ;;;;      ;;;   ;;       ;;;   
;                           ;;                             
;                           ;;                             
;                           ;;                             
;                                                          

(define ((convert-read orig-read/maybe-stx
                       [make-readtable make-current-command-char-readtable])
         . args)
  #;(->* [procedure?]
         [(-> readtable?)]
         procedure?)
  ;; based on wrap-reader from at-exp
  (parameterize
      ([current-readtable (make-readtable)])
    (apply orig-read/maybe-stx args)))


(define (convert-read-syntax orig-read-syntax
                             [make-readtable
                              make-current-command-char-readtable])
  #;(->* [procedure?]
         [(-> readtable?)]
         procedure?)
  (define read-syntax
    (convert-read orig-read-syntax make-readtable))
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


(define (read-language-error #:line line
                             #:col col
                             #:pos pos
                             #:in in
                             #:inner-lang lang
                             #:command-char [cmd-char (current-command-char)])
  (define-values (end-line end-col end-pos)
    (port-next-location in))
  (raise-read-error
   (cond
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
        (- end-pos pos))))
