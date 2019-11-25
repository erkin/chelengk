(import random)
(import [notes [add-koma]])

;;;; Scales and chords


;;; A dizi is a list of consecutive intervals.
;;; '(name interval interval interval)
(setv dörtlü-forms
      {'çargah ['tanini 'tanini 'bakiyye]
       'buselik ['tanini 'bakiyye 'tanini]
       'kürdi ['bakiyye 'tanini 'tanini]
       'rast ['tanini 'büyük-müneccep 'küçük-müneccep]
       ;; Hicaz is an inconsistent dörtlü due to artık ikilis varying length.
       ;; When artık ikili assumes the length of 13 koma instead of 12,
       ;;  the excess koma is taken from either the preceding or the
       ;;  following küçük müneccep.
       'hicaz ['küçük-müneccep 'artık-ikili 'küçük-müneccep]
       'hicaz-13 ['küçük-müneccep 'artık-ikili-13 'bakiyye]
       'hicaz-13* ['bakiyye 'artık-ikili-13 'küçük-müneccep]
       ;; Uşşak is used for tetrachords, whereas
       ;;  hüseyni is used for pentachords.
       'uşşak ['büyük-müneccep 'küçük-müneccep 'tanini]
       'hüseyni ['büyük-müneccep 'küçük-müneccep 'tanini]})

;;; A makam is made up of two diziler starting from a durak.
(setv makam-forms
      { ;; Fundamental (temel) makamlar
       'çargah ['çargah 'çargah 5 'çargah 4]
       'buselik ['dügah 'buselik 5 'kürdi 4]
       'kürdi ['dügah 'kürdi 4 'buselik 5]
       'rast ['rast 'rast 5 'rast 4]
       'neva ['dügah 'uşşak 4 'rast 5]
       'hüseyni ['dügah 'hüseyni 5 'uşşak 4]
       'karcığar ['dügah 'uşşak 4 'hicaz 5]
       'suzinak ['rast 'rast 5 'hicaz 4]
       'uşşak ['dügah 'uşşak 4 'buselik 5]
       ;; Hicaz-based makamlar
       'hicaz ['dügah 'hicaz 4 'rast 5]
       'hümayun ['dügah 'hicaz 4 'buselik 5]
       'uzzal ['dügah 'hicaz 5 'uşşak 4]
       'zirgüleli-hicaz ['dügah 'hicaz 5 'hicaz 4]
       ;; Synonyms for uşşak, hüseyni, neva and buselik respectively.
       'beyati ['dügah 'uşşak 4 'buselik 5]
       'muhayyer ['dügah 'hüseyni 5 'uşşak 4]
       'tahir ['dügah 'uşşak 4 'rast 5]
       'şehnaz-buselik ['dügah 'buselik 5 'kürdi 4]
       ;; Transposed 'göçürülmüş] makamlar
       ;; Çargah
       'mahur ['rast 'çargah 5 'çargah 4]
       'acemaşiran ['çargah 'çargah 5 'çargah 4]
       ;; Buselik
       'nihavent ['rast 'buselik 5 'kürdi 4]
       'ruhnevaz ['hüseyniaşiran 'buselik 5 'kürdi 4]
       'sultaniyegah ['rast 'buselik 5 'kürdi 4]
       ;; Kürdi
       'kürdilihicazkar ['rast 'kürdi 4 'buselik 5]
       'aşkefza ['hüseyniaşiran 'kürdi 4 'buselik 5]
       'ferahnüma ['yegah 'kürdi 4 'buselik 5]
       ;; Zirgüleli hicaz
       'zirgüleli-suzinak ['rast 'hicaz 5 'hicaz 4]
       'hicazkar ['rast 'hicaz 5 'hicaz 4]
       'evcara ['ırak 'hicaz-13 5 'hicaz-13 4]
       'suzidil ['hüseyniaşiran 'hicaz 5 'hicaz-13* 4]
       'şeddiaraban ['yegah 'hicaz 5 'hicaz 4]})

;;; There are three main types of diziler;
;;; Dörtlüler (quartets) are made up of three intervals.
;;; Üçlüler (triplets) are made up of dörtlüler lacking the final interval.
;;; Beşliler (quintets) are made up of dörtlüler with a tanini koma appended.
(defn make-dizi [durak name length]
  (setv intervals (cut (+ (get dörtlü-forms name) ['tanini]) 0 (dec length))
        results []
        previous durak)
  (for [interval intervals]
    (setv previous (add-koma previous interval))
    (.append results previous))
  results)

(defn make-makam [durak former-dizi former-length latter-dizi latter-length]
  (setv former (make-dizi durak former-dizi former-length)
        güçlü (last former)
        latter (make-dizi güçlü latter-dizi latter-length))
  (+ former (cut latter 1)))

(defn get-makam [name]
  (make-makam #* (get makam-forms name)))

(defn generate-perde [makam]
  (while True
    (yield (random.choice (get-makam makam)))))
