(ns chelengk.scales
  (:require [chelengk.notes :refer [add-koma]]))

(def dörtlüler
  {:çargah   '(:tanini :tanini :bakiyye)
   :buselik  '(:tanini :bakiyye :tanini)
   :kürdi    '(:bakiyye :tanini :tanini)
   :rast     '(:tanini :büyük-müneccep :küçük-müneccep)
   :hicaz    '(:küçük-müneccep :artık-ikili :küçük-müneccep)
   ;; To accomodate for artık ikili with koma value of 13.
   :hicaz-13 '(:küçük-müneccep :artık-ikili-13 :bakiyye)
   ;; Uşşak is used for tetrachords, whereas
   ;; hüseyni is used for pentachords.
   :uşşak    '(:büyük-müneccep :küçük-müneccep :tanini)
   :hüseyni  '(:büyük-müneccep :küçük-müneccep :tanini)})

;;; A makam is made up of two dörtlüler starting from a durak.
(def makamlar
  {;;; Fundamental (temel) makamlar
   :çargah            '(:çargah  :çargah 5  :çargah 4)
   :buselik           '(:dügah   :buselik 5 :kürdi 4)
   :kürdi             '(:dügah   :kürdi 4   :buselik 5)
   :rast              '(:rast    :rast 5    :rast 4)
   :neva              '(:dügah   :uşşak 4   :rast 5)
   :hüseyni           '(:dügah   :hüseyni 5 :uşşak 4)
   :karcığar          '(:dügah   :uşşak 4   :hicaz 5)
   :suzinak           '(:rast    :rast 5    :hicaz 4)
   :uşşak             '(:dügah   :uşşak 4   :buselik 5)
   ;; Hicaz-based makamlar
   :hicaz             '(:dügah  :hicaz 4 :rast 5)
   :hümayun           '(:dügah  :hicaz 4 :buselik 5)
   :uzzal             '(:dügah  :hicaz 5 :uşşak 4)
   :zirgüleli-hicaz   '(:dügah  :hicaz 5 :hicaz 4)
   ;; Synonyms for uşşak, hüseyni, neva and buselik respectively.
   :bayati            '(:dügah  :uşşak 4   :buselik 5)
   :muhayyer          '(:dügah  :hüseyni 5 :uşşak 4)
   :tahir             '(:dügah  :uşşak 4   :rast 5)
   :şehnaz-buselik    '(:dügah  :buselik 5 :kürdi 4)
   ;;; Transposed (göçürülmüş) makamlar
   ;; Çargah
   :mahur             '(:rast    :çargah 5 :çargah 4)
   :acemaşiran        '(:çargah  :çargah 5 :çargah 4)
   ;; Buselik
   :nihavent          '(:rast           :buselik 5 :kürdi 4)
   :ruhnevaz          '(:hüseyniaşiran  :buselik 5 :kürdi 4)
   :sultaniyegah      '(:rast           :buselik 5 :kürdi 4)
   ;; Kürdi
   :kürdilihicazkar   '(:rast           :kürdi 4 :buselik 5)
   :aşkefza           '(:hüseyniaşiran  :kürdi 4 :buselik 5)
   :ferahnüma         '(:yegah          :kürdi 4 :buselik 5)
   ;; Zirgüleli hicaz
   :zirgüleli-suzinak '(:rast           :hicaz 5    :hicaz 4)
   :hicazkar          '(:rast           :hicaz 5    :hicaz 4)
   :evcara            '(:ırak           :hicaz-13 5 :hicaz-13 4)
   :suzidil           '(:hüseyniaşiran  :hicaz 5    :hicaz-13 4)
   :şeddiaraban       '(:yegah          :hicaz 5    :hicaz 4)})

(defn make-dörtlü
  "Generate a dörtlü (tetrachord) from given `durak` (tonic).
  Üçlüler (trichords) are obtained by discarding the last interval of a
  tetrachord. Beşliler (pentachords) are obtained by appending a tanini
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
        5 (concat intervals '(:tanini)))))))

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
