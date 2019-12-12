(import [playback [holdrian]])
(import [midiutil [MIDIFile]])

(setv tempo 25)

(defn westernise [comma]
  (setv cents (round (* holdrian comma))
        semitones (// cents 100)
        shift (% cents 100)
        octave (// semitones 12)
        pitch (% semitones 12))
  (, (dec octave) pitch shift))

(defn midi-note [octave pitch]
  (+ (* (inc octave) 12) pitch))

(defn midi-bend [shift]
  (try
    (round (/ 8192 shift))
    (except [[ZeroDivisionError]]
      0)))

(defn make-midi [notes]
  (setv midi (doto (MIDIFile 1)
                   (.addTempo 0 0 tempo)
                   (.addProgramChange 0 0 0 106))
        bend 0)
  (for [note notes]
    (setv (, octave pitch shift) (westernise note.comma))
    (assert (< (midi-note octave pitch) 128))

    (.addPitchWheelEvent midi 0 0 note.offset (- bend))
    (.addNote midi 0 0 (midi-note octave pitch) note.offset note.duration note.velocity)
    (.addPitchWheelEvent midi 0 0 note.offset (midi-bend shift))

    (setv bend shift))
  midi)

(defn save-midi [midi path]
  (with [f (open path "wb")]
    (.writeFile midi f)))

(defn make-and-save-midi [notes path]
  (save-midi (make-midi notes) path))
