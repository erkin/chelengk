(import [os.path [join dirname realpath]]
        [sys [argv]]
        [operator [iconcat]])

;;;; Values and procedures of common use


(setv current-directory (dirname (realpath (get argv 0))))

(defn here [directory]
 ;; (+ "/content/" directory)
  (join current-directory directory))

(setv song-directory (here "SymbTr/txt"))

(defn invert-dict [dic]
  (dict (zip (.values dic) (.keys dic))))

(defn init [col]
  (tuple (cut (list col) 0 -1)))

(defn concat [lists]
  (reduce iconcat lists []))
