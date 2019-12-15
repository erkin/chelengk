(import [playback [holdrian]])
(import [random [choice]])
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
  (round (* 8192 (/ shift 100))))

(defn make-midi [notes]
  (setv midi (doto (MIDIFile 1)
                   (.addTempo 0 0 tempo)
                   (.addProgramChange 0 0 0 (choice [7 8 25 26
                                                     36 46 47
                                                     74 78 105
                                                     106 107 108])))
        bend 0
        offset 0.0)
  (for [note notes]
    (setv (, octave pitch shift) (westernise note.comma))

    (.addPitchWheelEvent midi 0 0 offset (- bend))
    (.addNote midi 0 0 (midi-note octave pitch) offset note.duration note.velocity)
    (.addPitchWheelEvent midi 0 0 offset (midi-bend shift))

    (setv bend shift
          offset (+ offset note.duration)))
  midi)

(defn save-midi [midi path]
  (with [f (open path "wb")]
    (.writeFile midi f)))

(defn make-and-save-midi [notes path]
  (save-midi (make-midi notes) path))
