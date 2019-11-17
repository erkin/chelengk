#lang racket/base

(provide (all-defined-out))

(require "const.rkt"
         "notes.rkt"
         "songs.rkt")
(require csv-writing)

;; Converting parsed songs to CSV format


(define (song->csv song)
  (define notes
    (filter
     (λ (n)
       ;; We only care about pronounced notes right now
       ;;  and we don't distinguish them yet.
       (memq (note-code n) '(7 8 9)))
     (song-notes song)))
  ;; HACK: We need to operate on pairs whilst traversing the list to
  ;;  convert the offset to durations. This means the first note is
  ;;  missed.
  (for/list ((fst (in-list notes))
             (snd (in-list (cdr notes))))
    (let ((pitch (comma->pitch (note-holdrian snd)))
          ;; Multiplied by 0.05 to fit the 0,0~1,0 interval.
          ;; Also to preserve ear health.
          (volume (* 0.05 (note-velocity snd)))
          (duration (ceiling (*
                              ;; 3.5 coefficient is hardcoded until
                              ;;  a tempo system is implemented.
                              3.5
                              ;; The difference between the offsets
                              ;;  is the length of the second.
                              (- (note-offset snd) (note-offset fst))))))
      (list pitch volume duration))))

(define (csv-write-song song)
  (with-output-to-file (build-path
                        csv-output-directory
                        (path-replace-extension (song-filename song) #".csv"))
    (λ () (display-table (song->csv song)))
    #:mode 'text))

(define (csv-write-all-songs)
  (for-each csv-write-song (read-all-songs)))
