#lang racket/base

(require "const.rkt"
         "playback.rkt")
(require racket/cmdline)

(module+ main
  (command-line
   #:program project-name
   #:once-each
   (("--version" "-v")
    "Show version and licence information"
    (displayln version-message)
    (exit)))

  ;; Exmaple use
  (play-makam 'uşşak)
  (sleep 1)
  (play-song "ussak--turku--sofyan--uzun_ince--asik_veysel.txt"))
