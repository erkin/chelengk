(import [collections [namedtuple]]
        csv
        [pathlib [Path]])
(import [const [song-directory]])

;;; SymbTr parser


(setv song (namedtuple 'song '(filename notes makam form usul title composer)))
(setv note (namedtuple 'note '(code holdrian velocity offset)))

(defn read-notes [path]
  (with [tsv (open path)]
    (setv reader (doto (csv.reader tsv :delimiter "\t") next))
    (lfor line reader
          ;; code, Holdrian, velocity, offset
          (note #* (map (fn [n] (get line n)) [1 4 10 12])))))

(defn read-song [path]
  (setv filename (. (Path path) stem))
  (song #* (+ [filename] [(read-notes path)] (.split filename "--"))))

(defn read-all-songs []
  (lfor path (.iterdir (Path song-directory))
        :if (.is_file path)
        (read-song path)))
