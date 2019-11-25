(import math)
(import [const [invert-dict]])

(setv holdrian 22.6415)

(setv root 16.35)

(setv komalar
      {'fazla          1
       'eksik-bakiyye  3
       'bakiyye        4
       'küçük-müneccep 5
       'büyük-müneccep 8
       'tanini         9
       'artık-ikili    12
       'artık-ikili-13 13})

(setv perdeler
      {'pause -1

       'kaba-rast 243

       'kaba-nim-zirgüle 247
       'kaba-zirgüle 248
       'kaba-dik-zirgüle 251

       'kaba-dügah 252

       'kaba-kürdi 256
       'kaba-dik-kürdi 259

       'kaba-segah 261

       'kaba-buselik 262
       'kaba-dik-buselik 265

       'kaba-çargah 266

       'kaba-nim-hicaz 269
       'kaba-hicaz 270
       'kaba-dik-hicaz 273

       'yegah 274

       'kaba-nim-hisar 278
       'kaba-hisar 279
       'kaba-dik-hisar 282

       'hüseyniaşiran 283

       'acemaşiran 287
       'dik-acemaşiran 288

       'ırak 291

       'geveşt 292
       'dik-geveşt 295

       'rast 296

       'nim-zirgüle 300
       'zirgüle 301
       'dik-zirgüle 304

       'dügah 305

       'kürdi 309
       'dik-kürdi 310

       'segah 313

       'buselik 314
       'dik-buselik 317

       'çargah 318

       'nim-hicaz 322
       'hicaz 323
       'dik-hicaz 326

       'neva 327

       'nim-hisar 331
       'hisar 332
       'dik-hisar 335

       'hüseyni 336

       'acem 340
       'dik-acem 341

       'eviç 344

       'mahur 345
       'dik-mahur 348

       'gerdaniye 349

       'nim-şehnaz 353
       'şehnaz 354
       'dik-şehnaz 357

       'muhayyer 358

       'sünbüle 362
       'dik-sünbüle 363

       'tiz-segah 366

       'tiz-buselik 367
       'tiz-dik-buselik 370

       'tiz-çargah 371

       'tiz-nim-hicaz 375
       'tiz-hicaz 376
       'tiz-dik-hicaz 379

       'tiz-neva 380

       'tiz-nim-hisar 384
       'tiz-hisar 385
       'tiz-dik-hisar 388

       'tiz-hüseyni 389

       'tiz-acem 393
       'tiz-dik-acem 394

       'tiz-eviç 397

       'tiz-mahur 398
       'tiz-dik-mahur 401

       'tiz-gerdaniye 402})

(setv inverse-perdeler (invert-dict perdeler))

(defn comma->pitch [comma]
  (if (= comma -1)
      0.0
      (* root (pow 2 (dec (/ (* holdrian comma) 1200))))))

(defn perde->pitch [perde]
  (comma->pitch (get perdeler perde)))

(defn add-koma [perde koma]
  (get inverse-perdeler (+ (get perdeler perde)
                           (get komalar koma))))
