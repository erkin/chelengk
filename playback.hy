(import [const [here]])
(import [numpy :as np]
        [numpy [sin pi float32]]
        pyaudio
        [struct [pack]]
        [time [time]]
        [threading [Thread Lock]]
        [scipy.io.wavfile :as wave])

;;;; PortAudio playback


(setv default-sample-rate 44100)
(setv holdrian 22.6415)
(setv root 16.35)

(defn comma->pitch [comma]
  (if (= comma -1) ; -1 indicates silence
      0.0
      (* root (pow 2 (dec (/ (* holdrian comma) 1200))))))

(defn saver-thunk [notes path]
  (setv start (time)
        data (make-tune notes))
  ;; (setv length (* (len data) 4))
  ;; (setv wave
  ;;       (+ (pack "<ccccIccccccccIHHIIHH"
  ;;                b"R" b"I" b"F" b"F" ; magic bytes
  ;;                (+ length 0x2c -8)  ; header size
  ;;                b"W" b"A" b"V" b"E" b"f" b"m" b"t" b" "
  ;;                0x10                      ; fmt header size
  ;;                3                         ; float32
  ;;                1                         ; channels
  ;;                default-sample-rate       ; samples/second
  ;;                (* 4 default-sample-rate) ; bytes/second
  ;;                4                         ; block alignment
  ;;                32)                       ; bits/sample
  ;;          (pack "<ccccI"
  ;;                b"d" b"a" b"t" b"a"
  ;;                length)
  ;;          (pack f"<{(len data)}f" #*data)))
  ;; (with [f (open path "wb")]
  ;;   (.write f wave))
  (wave.write path default-sample-rate (np.frombuffer data :dtype float32))
  (print "Written WAVE to" path "in" (round (- (time) start) 3) "seconds."))

(defn save-tune [notes path]
  (doto (Thread :target saver-thunk
                :args (, notes path)
                :daemon False)
        .start))

(defn make-sine-wave [pitch volume duration
                      &optional [sample-rate default-sample-rate]]
  (setv frames (np.arange :dtype float32 (* sample-rate duration)))
  (.tobytes (* volume (sin (* 2 pi (/ pitch sample-rate) frames)))))

(defn make-silence [duration &optional [sample-rate default-sample-rate]]
  (setv frames (np.arange :dtype float32 (* sample-rate duration)))
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
