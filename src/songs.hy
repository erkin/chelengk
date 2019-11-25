(import [collections [namedtuple]]
        csv
        [pathlib [Path]])
(import [const [song-directory]])

;;; SymbTr parser


(setv make-song (namedtuple 'song '(filename notes makam form usul title composer)))
(setv make-note (namedtuple 'note '(code holdrian velocity offset)))

(defn read-notes [path]
  (with [tsv (open path)]
    (setv reader (doto (csv.reader tsv :delimiter "\t") next))
    (lfor line reader
          :if (in (get line 1) ["7" "8" "9"])
          ;; code, Holdrian, velocity, offset
          (make-note #* (map (fn [n] (get line n)) [1 4 10 12])))))

(defn read-song [path]
  (setv filename (. (Path path) stem))
  (make-song #* (+ [filename] [(read-notes path)] (.split filename "--"))))

(defn read-all-songs []
  (lfor path (.iterdir (Path song-directory))
        :if (.is_file path)
        (read-song path)))
