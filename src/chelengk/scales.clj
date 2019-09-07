(ns chelengk.scales
  (:require [chelengk.notes :refer [add-koma]]))

(def dörtlüler
  {:çârgâh  '(:tanîni :tanîni :bakiye)
   :bûselik '(:tanîni :bakiye :tanîni)
   :kürdî   '(:bakiye :tanîni :tanîni)
   :uşşak   '(:küçük-müneccep :büyük-müneccep :tanîni)
   :hicaz   '(:küçük-müneccep :artık-ikili :küçük-müneccep)
   :rast    '(:tanîni :büyük-müneccep :küçük-müneccep)
   :hüseynî '(:büyük-mücennep :küçük-mücennep :tanîni)})

;;; A makam is made up of two dörtlüler starting from a durak.
(def makamlar
  {:çârgâh    '(:kaba-çârgâh :çârgâh 5 :çârgâh 4)
   :bûselik   '(:hüseynî :bûselik 5 :kürdî 4)
   :rast      '(:rast :rast 5 :rast 4)
   :uşşak     '(:dügâh :uşşak 4 :bûselik 5)})

(defn make-dörtlü
  "Generate a dörtlü (tetrachord) from given `durak` (tonic).
  Üçlüler (trichords) are obtained by discarding the last interval of a
  tetrachord. Beşliler (pentachords) are obtained by appending a tanîni
  (whole note) to a tetrachord."
  [durak name length]
  (let [intervals (dörtlüler name)]
    (reverse
     (reduce
      (fn [accumulator current-item]
        (conj accumulator (add-koma (first accumulator) current-item)))
      (list durak)
      (case length
        3 (drop-last intervals)
        4 intervals
        5 (concat intervals '(:tanîni)))))))

(defn make-makam
  "Generate two dörtlüler from `former-chord` and `latter-chord`, and
  chain them together to form a makam. Given `durak` is the tonic of the
  scale. No güçlü (dominant) needs to be provided, as it's the last note
  of the former dörtlü."
  [durak
   former-chord former-length
   latter-chord latter-length]
  (let [former (make-dörtlü durak former-chord former-length)]
    (concat former (rest (make-dörtlü (last former) latter-chord latter-length)))))

(defn get-makam [makam]
  (apply make-makam (makamlar makam)))
