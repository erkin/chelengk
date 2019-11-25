(import [collections [namedtuple]]
        csv
        [pathlib [Path]])
(import [const [song-directory]])

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

(setv make-song (namedtuple 'song '(filename notes makam form usul title composer)))
(setv make-note (namedtuple 'note '(comma velocity duration)))

(defn read-notes [path]
  (with [tsv (open path)]
    (setv lines (list (doto (csv.reader tsv :delimiter "\t") next))))
  ;; HACK: Skips the last line of the file, which has no duration.
  (lfor (, line0 line1) (zip lines (rest lines))
        :if (and (in (get line0 1) useful-notes) ; Only take note lines
                 (in (get line1 1) useful-notes))
        (make-note (int (get line0 4))       ; Holdrian comma
                   (int (get line0 10))      ; Velocity
                   (- (float (get line1 12)) ; Duration
                      (float (get line0 12))))))

(defn read-song [path]
  (setv filename (. (Path path) stem))
  (make-song #* (+ [filename] [(read-notes path)] (.split filename "--"))))

(defn read-song-from-library [filename]
  (read-song (Path song-directory filename)))

(defn read-all-songs-from-library []
  (lfor path (.iterdir (Path song-directory))
        :if (.is_file path)
        (read-song path)))
