(import [collections [namedtuple]]
        csv
        [pathlib [Path]])
(import [const [song-directory]])

;;; SymbTr parser


(setv make-song (namedtuple 'song '(filename notes makam form usul title composer)))
(setv make-note (namedtuple 'note '(comma velocity duration)))

;;; I'm ashamed of myself for this rushed mess...
;;; TODO: Rewrite this
(defn read-notes [path]
  (with [tsv (open path)]
    ;; Skip the first line which contains the column info
    (setv reader (doto (csv.reader tsv :delimiter "\t") next)
          ;; Read the first line separately
          temp-line (next reader)
          ;; Save info of the first line
          prev-comma (get temp-line 4)
          prev-velocity (get temp-line 10)
          prev-offset 0.0
          notes [])
    ;; Start reading the remaining n-2 lines
    (for [line reader]
      ;; Only get playable notes
      ;; TODO: Add trills etc
      :if (in (get line 1) ["7" "8" "9"])
      ;; TODO: Read tempo
      (setv offset (get line 12))
      ;; Construct the previous note using the current offset.
      (.append notes (make-note (int prev-comma) (int prev-velocity)
                                ;; Subtract offsets to find the length
                                (- (float offset) (float prev-offset))))
      ;; Stash the current note's info for the next iteration so that we
      ;;  can build it using the next note's offset info.
      (setv prev-comma (get line 4)
            prev-velocity (get line 10)
            prev-offset offset)))
  ;; The last note has no length info, so we add it separately as 0.5
  (.append notes (make-note (int prev-comma) (int prev-velocity) 0.5))
  notes)

(defn read-song [path]
  (setv filename (. (Path path) stem))
  (make-song #* (+ [filename] [(read-notes path)] (.split filename "--"))))

(defn read-song-from-library [filename]
  (read-song (Path song-directory filename)))

(defn read-all-songs-from-library []
  (lfor path (.iterdir (Path song-directory))
        :if (.is_file path)
        (read-song path)))
