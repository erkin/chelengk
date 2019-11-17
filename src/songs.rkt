#lang racket/base

(provide read-all-songs
         read-song
         (struct-out song)
         (struct-out note))

(require "const.rkt")
(require racket/file
         racket/match
         racket/path
         racket/string)

;;;; SymbTr parser


(struct song (filename notes makam form usul title composer) #:transparent)
(struct note (code holdrian arel velocity offset) #:transparent)

(define (read-notes path)
  (map
   (λ (line)
     (match (string-split line "\t" #:trim? #f)
       ((list _ code _ _ holdrian arel _ _ _ _ velocity _ offset)
        (apply note (map string->number (list code holdrian arel velocity offset))))))
   (cdr (file->lines path))))

(define (read-song path)
  (define filename (path-replace-extension (file-name-from-path path) #""))
  (match-let (((list makam form usul title composer)
               (string-split (path->string filename) "--" #:trim? #f)))
    (song filename (read-notes path) makam form usul title composer)))

(define (read-all-songs)
  (parameterize ((current-directory song-directory))
    (for/list ((path (in-directory)))
      (read-song path))))
