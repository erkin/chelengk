#lang racket/base

(provide (all-defined-out))

(define project-name "Chelengk")
(define project-version "v0.1.0")

(define song-directory "SymbTr/txt")

(define (invert-alist alist)
  (define (invert-alist-iter alist result)
    (if (null? alist)
        (reverse result)
        (invert-alist-iter (cdr alist)
                           (cons (cons (cdar alist) (caar alist)) result))))
  (invert-alist-iter alist '()))

(define version-message
  (format #<<version
~a ~a
Copyright (C) 2019 Erkin Batu Altunbaş

Each file of this project's source code is subject
to the terms of the Mozilla Public Licence v2.0
https://mozilla.org/MPL/2.0/
version
          project-name project-version))
