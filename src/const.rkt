#lang racket/base

(define (invert-alist alist)
  (define (invert-alist-iter alist result)
    (if (null? alist)
        (reverse result)
        (invert-alist-iter (cdr alist)
                           (cons (cons (cdar alist) (caar alist)) result))))
  (invert-alist-iter alist '()))