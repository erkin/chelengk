(import [os.path [dirname]]
        [collections [__file__ :as this-file]])

(setv song-directory (+ (dirname this-file) "/SymbTr/txt"))

(defn invert-dict [dic]
  (dict (zip (.values dic) (.keys dic))))
