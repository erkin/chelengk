#lang racket/base

(provide play-song
         play-makam
         record-song)

(require "const.rkt"
         "notes.rkt"
         "scales.rkt"
         "songs.rkt")
(require rsound)

;;;; Portaudio playback


(define (sound-length sound)
  (/ (rs-frames sound)
     (rsound-sample-rate sound)))

;;; We need to wait for the song to end, because it's being played
;;;  asynchronously.
(define (play-and-wait sound)
  (play sound)
  (sleep (sound-length sound))
  (stop))

(define (play-makam makam)
  (~>> (get-makam makam)
       (map (λ (perde)
              (make-tone (perde->freq perde) 1 (default-sample-rate))))
       (rs-append*)
       (play-and-wait)))

(define (make-song path)
  (define notes
    (filter
     (λ (n)
       ;; We only care about pronounced notes right now
       ;;  and we don't distinguish them yet.
       (memq (note-code n) '(7 8 9)))
     (song-notes (read-song (string-append song-directory "/" path)))))
  (rs-append*
   ;; HACK: We need to operate on pairs whilst traversing the list to
   ;;  convert the offset to durations. This means the first note is
   ;;  missed.
   (for/list ((fst (in-list notes))
              (snd (in-list (cdr notes))))
     (let ((pitch (comma->freq (note-holdrian snd)))
           ;; Multiplied by 0.05 to fit the 0,0~1,0 interval.
           ;; Also to preserve ear health.
           (volume (* 0.05 (note-velocity snd)))
           (duration (round (* (default-sample-rate)
                               ;; 3.5 coefficient is hardcoded until
                               ;;  a tempo system is implemented.
                               3.5
                               ;; The difference between the offsets
                               ;;  is the length of the second.
                               (- (note-offset snd) (note-offset fst))))))
       ;; A value of 0.0 indicates a pause.
       (if (zero? pitch)
           (silence duration)
           (make-tone pitch volume duration))))))

(define (play-song path)
  (play-and-wait (make-song path)))

(define (record-song path out-path)
  (rs-write (make-song path) out-path))
