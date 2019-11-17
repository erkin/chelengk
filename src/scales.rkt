#lang racket/base

(provide get-makam generate-perde)

(require "notes.rkt")
(require racket/generator
         racket/list)

;;;; Scales and chords


;;; A dizi is a list of consecutive intervals.
;;; '(name interval interval interval)
(define dörtlü-form-alist
  '((çargah tanini tanini bakiyye)
    (buselik tanini bakiyye tanini)
    (kürdi bakiyye tanini tanini)
    (rast tanini büyük-müneccep küçük-müneccep)
    ;; Hicaz is an inconsistent dörtlü due to artık ikilis varying length.
    ;; When artık ikili assumes the length of 13 koma instead of 12,
    ;;  the excess koma is taken from either the preceding or the
    ;;  following küçük müneccep.
    (hicaz küçük-müneccep artık-ikili küçük-müneccep)
    (hicaz-13 küçük-müneccep artık-ikili-13 bakiyye)
    (hicaz-13* bakiyye artık-ikili-13 küçük-müneccep)
    ;; Uşşak is used for tetrachords, whereas
    ;;  hüseyni is used for pentachords.
    (uşşak büyük-müneccep küçük-müneccep tanini)
    (hüseyni büyük-müneccep küçük-müneccep tanini)))

;;; A makam is made up of two diziler starting from a durak.
(define makam-form-alist
  '(;; Fundamental (temel) makamlar
    (çargah çargah çargah 5 çargah 4)
    (buselik dügah buselik 5 kürdi 4)
    (kürdi dügah kürdi 4 buselik 5)
    (rast rast rast 5 rast 4)
    (neva dügah uşşak 4 rast 5)
    (hüseyni dügah hüseyni 5 uşşak 4)
    (karcığar dügah uşşak 4 hicaz 5)
    (suzinak rast rast 5 hicaz 4)
    (uşşak dügah uşşak 4 buselik 5)
    ;; Hicaz-based makamlar
    (hicaz dügah hicaz 4 rast 5)
    (hümayun dügah hicaz 4 buselik 5)
    (uzzal dügah hicaz 5 uşşak 4)
    (zirgüleli-hicaz dügah hicaz 5 hicaz 4)
    ;; Synonyms for uşşak, hüseyni, neva and buselik respectively.
    (beyati dügah uşşak 4 buselik 5)
    (muhayyer dügah hüseyni 5 uşşak 4)
    (tahir dügah uşşak 4 rast 5)
    (şehnaz-buselik dügah  buselik 5 kürdi 4)
    ;;; Transposed (göçürülmüş) makamlar
    ;; Çargah
    (mahur rast çargah 5 çargah 4)
    (acemaşiran çargah çargah 5 çargah 4)
    ;; Buselik
    (nihavent rast buselik 5 kürdi 4)
    (ruhnevaz hüseyniaşiran  buselik 5 kürdi 4)
    (sultaniyegah rast buselik 5 kürdi 4)
    ;; Kürdi
    (kürdilihicazkar rast kürdi 4 buselik 5)
    (aşkefza hüseyniaşiran  kürdi 4 buselik 5)
    (ferahnüma yegah kürdi 4 buselik 5)
    ;; Zirgüleli hicaz
    (zirgüleli-suzinak rast hicaz 5 hicaz 4)
    (hicazkar rast hicaz 5 hicaz 4)
    (evcara ırak hicaz-13 5 hicaz-13 4)
    (suzidil hüseyniaşiran  hicaz 5 hicaz-13* 4)
    (şeddiaraban yegah hicaz 5 hicaz 4)))

(define dörtlü-forms
  (make-immutable-hasheq dörtlü-form-alist))

(define makam-forms
  (make-immutable-hasheq makam-form-alist))

;;; There are three main types of diziler;
;;; Dörtlüler (quartets) are made up of three intervals.
;;; Üçlüler (triplets) are made up of dörtlüler lacking the final interval.
;;; Beşliler (quintets) are made up of dörtlüler with a tanini koma appended.
(define (make-dizi durak name length)
  (let* ((intervals
          (take (append (hash-ref dörtlü-forms name)
                        (list 'tanini))
                (sub1 length))))
    (for/fold ((accumulator (list durak))
               #:result (reverse accumulator))
              ((interval (in-list intervals)))
      (cons (add-koma (car accumulator) interval) accumulator))))

(define (make-makam durak former-dizi former-length latter-dizi latter-length)
  (let* ((former (make-dizi durak former-dizi former-length))
         (güçlü (last former))
         (latter (make-dizi güçlü latter-dizi latter-length)))
    (append former (cdr latter))))

(define (get-makam name)
  (apply make-makam (hash-ref makam-forms name)))

(define makams
  (map
   (λ (makam-form)
     (get-makam (car makam-form)))
   makam-form-alist))

(define generate-perde
  (generator (makam)
             (let loop ()
               (yield (car (shuffle (get-makam makam))))
               (loop))))
