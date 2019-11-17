#lang racket/base

(require "const.rkt"
         "csv.rkt"
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


  ;;; Exmaple uses
  ;; (play-makam 'evcara)
  ;; (play-perde 'yegah)
  ;; (improvise-on 'rast 10)
  ;; (play-song "ussak--turku--sofyan--uzun_ince--asik_veysel.txt")
  ;; (record-song "hicaz--turku--sofyan--bahce_duvarini--neset_ertas.txt")
  ;; (csv-write-song "kurdilihicazkar--sarki--semai--uzun_yillar--zeki_muren.txt")
  )
