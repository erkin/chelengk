#lang racket/base

(require racket/cmdline
         racket/function
         racket/pretty)
(require threading)

(require "const.rkt"
         "notes.rkt"
         "scales.rkt"
         "songs.rkt")


(module+ main
  (command-line
   #:program project-name
   #:once-each
   (("--version" "-v")
    "Show version and licence information"
    (displayln version-message)
    (exit)))

  ;; Example use
  (~>> (read-all-songs)
       caddr
       song-notes
       (map note-holdrian)
       (filter (curry < 200))
       (for-each (compose pretty-print (curry hash-ref inverse-perdeler)))))
