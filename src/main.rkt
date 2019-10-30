#lang racket/base

(require "notes.rkt"
         "scales.rkt"
         "songs.rkt")


(module+ main
(define songs (read-all-songs)))
