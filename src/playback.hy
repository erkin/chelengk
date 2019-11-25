(import [const [song-directory]]
        [notes [comma->pitch]]
        [songs [read-song]])
(import pyaudio
        [numpy [arange sin pi float32]])

(setv default-sample-rate 44100)

(defn initialise-pyaudio []
  (pyaudio.PyAudio))

(defn finalise-pyaudio [p]
  (.terminate p))

(defn initialise-stream [p &optional [sample-rate default-sample-rate]]
  (.open p
         :format pyaudio.paFloat32
         :channels 1
         :rate sample-rate
         :output True))

(defn finalise-stream [stream]
  (.stop_stream stream)
  (.close stream))

(defn make-sine-wave [pitch volume duration
                      &optional [sample-rate default-sample-rate]]
  (.tobytes
    (* volume
       (sin (* 2 pi
               (arange :dtype float32 (* sample-rate duration))
               (/ pitch sample-rate))))))

(defn make-silence [duration &optional [sample-rate default-sample-rate]]
  (.tobytes (* 0 (arange (* sample-rate duration) :dtype float32))))

(defn make-tune [song]
  (setv notes (. song notes)
        tune [])
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

(defn play-tune [song]
  (setv p (initialise-pyaudio)
        stream (initialise-stream p))
  (.write stream (make-tune song))
  (finalise-stream stream)
  (finalise-pyaudio p))
