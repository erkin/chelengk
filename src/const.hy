(setv song-directory "SymbTr/txt")

(defn sub1 [n] (- n 1))
(defn add1 [n] (+ n 1))

(defn invert-dict [dic]
  (dict (zip (.values dic) (.keys dic))))
