(import [os.path [join dirname realpath]]
        [sys [argv]]
        [operator [iconcat]])

(setv current-directory (dirname (realpath (get argv 0))))

(defn here [directory]
  (join current-directory directory))

(setv song-directory (join current-directory "SymbTr/txt"))

(defn invert-dict [dic]
  (dict (zip (.values dic) (.keys dic))))

(defn init [col]
  (cut (list col) 0 -1))

(defn concat [lists]
  (reduce iconcat lists []))
