(setv song-directory "SymbTr/txt")

(defn invert-dict [dic]
  (dict (zip (.values dic) (.keys dic))))
