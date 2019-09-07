(ns chelengk.notes
  (:require [clojure.set :refer [map-invert]]))

(defn- make-bidimap
  "Merge `map` with its inverse to get a crude approximation of
  a bidirectional map."
  [map]
  (merge map (map-invert map)))

;;; A koma is an interval between perdeler. The interval between two
;;; perde are divided into nine komalar (one tanîni).
(def komalar
  (make-bidimap
   {:fazla 1
    :eksik-bakiye 3
    :bakiye 4
    :küçük-müneccep 5
    :büyük-müneccep 8
    :tanîni 9
    :artık-ikili 12}))

(def perdeler
  (make-bidimap
   {:kaba-çârgâh 0
    :kaba-nim-hicaz 4
    :kaba-hicaz 5
    :kaba-dik-hicaz 8
    :yegâh 9
    :kaba-nim-hisar 13
    :kaba-hisar 14
    :kaba-dik-hisar 17
    :hüseynî-aşîrân 18
    :acem-aşîrân 22
    :dik-acem-aşiran 23
    :ırak 26
    :gevest 27
    :dik-gevest 30
    :rast 31
    :nim-zirgüle 35
    :zirgüle 36
    :dik-zirgüle 39
    :dügâh 40
    :kürdî 44
    :dik-kürdî 45
    :segâh 48
    :bûselik 49
    :dik-bûselik 52
    :çârgâh 53
    :nim-hicaz 57
    :hicaz 58
    :dik-hicaz 61
    :nevâ 62
    :nim-hisar 66
    :hisar 67
    :dik-hisar 70
    :hüseynî 71
    :acem 75
    :dik-acem 76
    :eviç 79
    :mahur 80
    :dik-mahur 83
    :gerdâniye 84
    :nim-şehnâz 88
    :şehnâz 89
    :dik-şehnâz 92
    :muhayyer 93
    :sünbüle 97
    :dik-sünbüle 98
    :tîz-segâh 101
    :tîz-bûselik 102
    :tîz-dik-bûselik 105
    :tîz-çârgâh 106}))

(defn add-koma
  "Add the value of `koma` to `perde`'s value, return the name of the
  resulting perde."
  [perde koma]
  (perdeler (+ (perdeler perde) (komalar koma))))
