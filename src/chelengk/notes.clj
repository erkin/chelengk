(ns chelengk.notes
  (:require [clojure.set :refer [map-invert]]))

(defn- make-bidimap
  "Merge `map` with its inverse to get a crude approximation of
  a bidirectional map."
  [map]
  (merge map (map-invert map)))

;;; A koma is an interval between perdeler. The interval between two
;;; perde are divided into nine komalar (one tanini).
(def komalar
  {:fazla 1
   :eksik-bakiyye 3
   :bakiyye 4
   :küçük-müneccep 5
   :büyük-müneccep 8
   :tanini 9
   :artık-ikili 12
   :artık-ikili-13 13})

(def perdeler
  (make-bidimap
   {:kaba-çargah 0
    :kaba-nim-hicaz 4
    :kaba-hicaz 5
    :kaba-dik-hicaz 8
    :yegah 9
    :kaba-nim-hisar 13
    :kaba-hisar 14
    :kaba-dik-hisar 17
    :hüseyniaşiran 18
    :acemaşiran 22
    :dik-acemaşiran 23
    :ırak 26
    :gevest 27
    :dik-gevest 30
    :rast 31
    :nim-zirgüle 35
    :zirgüle 36
    :dik-zirgüle 39
    :dügah 40
    :kürdi 44
    :dik-kürdi 45
    :segah 48
    :buselik 49
    :dik-buselik 52
    :çargah 53
    :nim-hicaz 57
    :hicaz 58
    :dik-hicaz 61
    :neva 62
    :nim-hisar 66
    :hisar 67
    :dik-hisar 70
    :hüseyni 71
    :acem 75
    :dik-acem 76
    :eviç 79
    :mahur 80
    :dik-mahur 83
    :gerdaniye 84
    :nim-şehnaz 88
    :şehnaz 89
    :dik-şehnaz 92
    :muhayyer 93
    :sünbüle 97
    :dik-sünbüle 98
    :tiz-segah 101
    :tiz-buselik 102
    :tiz-dik-buselik 105
    :tiz-çargah 106}))

(defn add-koma
  "Add the value of `koma` to `perde`'s value, return the name of the
  resulting perde."
  [perde koma]
  (perdeler (+ (perdeler perde) (komalar koma))))
