#lang racket/base

(require (only-in "scales.rkt" get-makam))

(module+ main
  ;; Rast makam example
  (displayln (get-makam 'rast)))
