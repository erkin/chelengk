#lang racket/base

(provide add-koma comma->freq perde->freq inverse-perdeler)

(require "const.rkt")

;;;; Notes, commas and frequencies


#| I hope I understand this stuff correctly...

perde (pl perdeler): A specific note, especially one with a name.
koma (pl komalar): An interval that is defined as a Holdrian comma in Arel-Ezgi
      system. Each whole note is divided into nine komalar. Specific intervals
      are defined through komalar and have individual names.

Holdrian comma: The smallest interval of 53TET. Exactly 22,6415 cents.
53TET: 53 tone equal temperament. A system of tuning that breaks up an octave
       into 53 intervals. An octave is still 1200 cents wide.

|#


(define holdrian 22.6415)

;;; Frequency of C0 of 53TET in hertz.
(define root 16.35)

(define koma-alist
  '((fazla . 1)
    (eksik-bakiyye . 3)
    (bakiyye . 4)
    (küçük-müneccep . 5)
    (büyük-müneccep . 8)
    (tanini . 9)
    ;; Artık ikili can be 13 to fill a gap worth a fazla.
    (artık-ikili . 12)
    (artık-ikili-13 . 13)))

;;; Each perde corresponds to a Holdrian comma distance from C0.
;;; ie C0 is 1 and C5 is 1 + 5 * 53 = 266, which is kaba çargah
(define perde-alist
  '((pause . -1)

    (kaba-rast . 243)

    (kaba-nim-zirgüle . 247)
    (kaba-zirgüle . 248)
    (kaba-dik-zirgüle . 251)

    (kaba-dügah . 252)

    (kaba-kürdi . 256)
    (kaba-dik-kürdi . 259)

    (kaba-segah . 261)

    (kaba-buselik . 262)
    (kaba-dik-buselik . 265)

    (kaba-çargah . 266)

    (kaba-nim-hicaz . 269)
    (kaba-hicaz . 270)
    (kaba-dik-hicaz . 273)

    (yegah . 274)

    (kaba-nim-hisar . 278)
    (kaba-hisar . 279)
    (kaba-dik-hisar . 282)

    (hüseyniaşiran . 283)

    (acemaşiran . 287)
    (dik-acemaşiran . 288)

    (ırak . 291)

    (geveşt . 292)
    (dik-geveşt . 295)

    (rast . 296)

    (nim-zirgüle . 300)
    (zirgüle . 301)
    (dik-zirgüle . 304)

    (dügah . 305)

    (kürdi . 309)
    (dik-kürdi . 310)

    (segah . 313)

    (buselik . 314)
    (dik-buselik . 317)

    (çargah . 318)

    (nim-hicaz . 322)
    (hicaz . 323)
    (dik-hicaz . 326)

    (neva . 327)

    (nim-hisar . 331)
    (hisar . 332)
    (dik-hisar . 335)

    (hüseyni . 336)

    (acem . 340)
    (dik-acem . 341)

    (eviç . 344)

    (mahur . 345)
    (dik-mahur . 348)

    (gerdaniye . 349)

    (nim-şehnaz . 353)
    (şehnaz . 354)
    (dik-şehnaz . 357)

    (muhayyer . 358)

    (sünbüle . 362)
    (dik-sünbüle . 363)

    (tiz-segah . 366)

    (tiz-buselik . 367)
    (tiz-dik-buselik . 370)

    (tiz-çargah . 371)

    (tiz-nim-hicaz . 375)
    (tiz-hicaz . 376)
    (tiz-dik-hicaz . 379)

    (tiz-neva . 380)

    (tiz-nim-hisar . 384)
    (tiz-hisar . 385)
    (tiz-dik-hisar . 388)

    (tiz-hüseyni . 389)

    (tiz-acem . 393)
    (tiz-dik-acem . 394)

    (tiz-eviç . 397)

    (tiz-mahur . 398)
    (tiz-dik-mahur . 401)

    (tiz-gerdaniye . 402)))

;;; Symbol to number
(define komalar
  (make-immutable-hasheq koma-alist))

;;; Symbol to number
(define perdeler
  (make-immutable-hasheq perde-alist))

;;; Number to symbol
(define inverse-perdeler
  (make-immutable-hasheqv (invert-alist perde-alist)))


;;; Convert Holdrian comma distance from C0 to hertz
(define (comma->freq comma)
  ;; A comma value of -1 indicates a pause.
  (if (= comma -1)
      0.0
      (* root (expt 2 (sub1 (/ (* holdrian comma) 1200))))))

;;; Convert perde (symbol) to frequency
(define (perde->freq perde)
  (comma->freq (hash-ref perdeler perde)))

(define (add-koma perde koma)
  (hash-ref inverse-perdeler
            (+ (hash-ref perdeler perde)
               (hash-ref komalar koma))))
