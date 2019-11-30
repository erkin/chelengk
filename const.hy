(import [os.path [dirname realpath]]
        [sys [argv]])

(setv song-directory (+ (dirname (realpath (get argv 0))) "/SymbTr/txt"))

(defn invert-dict [dic]
  (dict (zip (.values dic) (.keys dic))))

(defn init [lst]
  (cut lst 0 -1))
