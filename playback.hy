(import [numpy [arange sin pi float32]]
        pyaudio
        [threading [Thread Lock]])

;;;; PortAudio playback


(setv default-sample-rate 44100)
(setv holdrian 22.6415)
(setv root 16.35)

(defn comma->pitch [comma]
  (if (= comma -1) ; -1 indicates silence
      0.0
      (* root (pow 2 (dec (/ (* holdrian comma) 1200))))))

(defn make-sine-wave [pitch volume duration
                      &optional [sample-rate default-sample-rate]]
  (setv frames (arange :dtype float32 (* sample-rate duration)))
  (.tobytes (* volume (sin (* 2 pi (/ pitch sample-rate) frames)))))

(defn make-silence [duration &optional [sample-rate default-sample-rate]]
  (setv frames (arange :dtype float32 (* sample-rate duration)))
  (.tobytes (* 0 frames)))

(defn make-tune [notes]
  (setv tune [])
  (for [note notes]
    (setv pitch (comma->pitch note.comma)
          volume (* 0.03 note.velocity)
          ;; TODO: Add tempo
          duration (* 5 note.duration))
    (unless (zero? duration)
      (.append tune
               (if (zero? pitch)
                   (make-silence duration)
                   (make-sine-wave pitch volume duration)))))
  (+ #* tune))

(defn play-tune [notes]
  (setv p (pyaudio.PyAudio))
  (doto (.open
          p
          :format pyaudio.paFloat32
          :channels 1
          :rate default-sample-rate
          :output True)
        (.write (make-tune notes))
        .stop_stream
        .close)
  (.terminate p))

(setv lock (Lock))

(defn audio-thunk [notes]
  (global lock)
  (.acquire lock)
  (play-tune notes)
  (.release lock))

(defn play-threaded-tune [notes]
  (global lock)
  ;; Just return nil if the lock is taken.
  (unless (.locked lock)
    (doto (Thread :target audio-thunk
                  :args (, notes)
                  :daemon True)
          .start)))
