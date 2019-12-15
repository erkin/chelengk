(require [macros [defattrs]])
(import [const [song-directory]])
(import csv
        [pathlib [Path]]
        re
        [sys [stderr]])

;;; SymbTr parser


(setv useful-notes
      [ ;; Ordinary note
       "9" "10"
       ;; Grace note
       "8" "11"
       ;; Glissando
       "4"
       ;; Tremolo
       "7" "16"
       ;; Trill
       "1" "12" "32"
       ;; Mordent
       "23" "24" "43" "44"
       ;; Embellishment
       "1" "28"])

(defattrs Note [object] []
  [[comma :converter int]
   [velocity :converter int]
   [duration :converter (fn [val] (round val 2))]]
  (defn get-values [self]
    (, self.comma
       self.duration)))

(defattrs Song [object] []
  [notes filename makam form usul title composer]
  (defn get-notes [self]
    (lfor note (. self notes) (.get-values note)))
  (defn get-metadata [self]
    (, self.makam
       self.form
       self.usul
       self.title
       self.composer)))

(defn read-notes [path]
  (with [tsv (open path)]
    (try
      (setv dialect (.sniff (csv.Sniffer) (.read tsv 1024)))
      ;; Let's make sure this is a real TSV file.
      (assert (= (. dialect delimiter) "\t"))
      (setv lines (list (doto (csv.reader tsv :delimiter "\t") next)))
      ;; Return nil if we determine the file is corrupt.
      (except [[csv.Error AssertionError StopIteration]]
        (print :file stderr "Warning: Not loading invalid file:" path))
      ;; HACK: Skips the last note of the file, which has no duration.
      (else
        (lfor (, line0 line1) (zip lines (rest lines))
              :if (and (in (get line0 1) useful-notes) ; Only take note lines
                       (in (get line1 1) useful-notes))
              (Note
                (get line0 4)             ; Holdrian comma
                (get line0 10)            ; Velocity
                (- (float (get line1 12)) ; Duration
                   (float (get line0 12)))))))))

(defn read-song [path]
  (setv filename (. (Path path) stem)
        metadata (.split filename "--")
        notes (read-notes path))
  ;; Just return nil if `notes' is nil.
  (when notes
    (try
      (assert (= (len metadata) 5))
      (except [[AssertionError]]
        (print :file stderr "Warning: Filename invalid:" filename)
        ;; Dummy metadata
        (setv metadata (* ["fnord"] 5))))
    (Song notes filename #*metadata)))

(defn read-all-songs-from-library []
  (lfor path (.iterdir (Path song-directory))
        :if (.is_file path)
        :setv song (read-song path)
        :if song
        song))

(defn read-songs [category]
  (lfor path (.iterdir (Path song-directory))
        :if (and
              ;; Is this a file?
              (.is_file path)
              ;; Is the category we're searching for?
              (re.search (+ "--" category "--") (. path stem)))
        :setv song (read-song path)
        ;; Did we parse it successfully?
        :if song
        song))

