(import [songs [read-songs make-dummy-song]]
        [const [init invert-dict here]])
(import time pickle)
(import [numpy :as np]
        [tensorflow.keras [Sequential]]
        [tensorflow.keras.layers
         [LSTM Dense Activation Dropout Embedding TimeDistributed]])

;;;; Keras LSTM music generation


(setv sequence-length 64)
(setv batch-size 16)
(setv epochs 10)

(defn get-notes [category]
  (setv notes [])
  (for [song (read-songs category)]
    ;; Drop the duration field and flatten the notes.
    ;; (.extend notes (concat (map init (. song notes))))
    ;; Concatenate the comma values of the songs.
    (.extend notes (map first (. song notes))))
  notes)

(defn read-batch [notes uniques]
  (setv batch (int (/ (get notes.shape 0) batch-size)) ; Batch shape
        batch-count (range 0 (- batch sequence-length) sequence-length))
  (for [start batch-count] ; Batch
    (setv x (np.zeros (, batch-size sequence-length))
          y (np.zeros (, batch-size sequence-length uniques)))
    (for [index (range 0 batch-size)]    ; Batch row
      (for [i (range 0 sequence-length)] ; Batch column
        (setv (get x (, index i))
              (get notes (+ start i (* index batch))))
        (setv (get y (, index i (get notes (+ start i 1 (* index batch)))))
              1)))
    (yield (, x y))))

(defn build-model [uniques &kwonly [mode "training"]]
  (doto (Sequential)
        (.add (Embedding
                :input_dim uniques
                :output_dim 512
                :batch_input_shape (if (= mode "training")
                                       (, batch-size sequence-length)
                                       (, 1 1))))
        (.add (LSTM
                256
                :return_sequences True
                :stateful True))
        (.add (Dropout 0.2))
        (.add (LSTM
                256
                :return_sequences True
                :stateful True))
        (.add (Dropout 0.2))
        (.add (LSTM
                256
                :return_sequences (= mode "training")
                :stateful True))
        (.add (Dropout 0.2))
        (.add (if (= mode "training")
                  (TimeDistributed (Dense uniques))
                  (Dense uniques)))
        (.add (Activation "softmax"))))

(defn train-network [category]
  (setv start (time.time)
        notes (get-notes category)
        indices (dfor (, index note) (enumerate (sorted (set notes)))
                      [note index])
        indexed-notes (np.asarray (lfor note notes (get indices note)) :dtype np.int32)
        uniques (len indices)
        songs-read (time.time))
  (print "Songs read and serialised in" (round (- songs-read start) 3) "seconds.")

  (with [f (open (here (.format "output/{}-indices.dat" category)) "wb")]
    (pickle.dump indices f))

  (setv model (doto (build-model uniques)
                    (.summary)
                    (.compile :loss "categorical_crossentropy"
                              :optimizer "adam"
                              :metrics ["accuracy"])))
  (setv epoch-number []
        loss []
        accuracy [])
  (for [epoch (range epochs)]
    (print "Epoch" (inc epoch) "of" epochs)
    (setv final-loss 0
          final-accuracy 0)
    (.append epoch-number (inc epoch))
    (for [(, i (, x y))
          (enumerate (read-batch indexed-notes uniques))]
      (setv (, final-loss
               final-accuracy) (.train_on_batch model x y))
      (print "Batch:" (inc i)
             "/ Loss:" (round final-loss 3)
             "/ Accuracy:" (round final-accuracy 3)))
    (.append loss final-loss)
    (.append accuracy final-accuracy)
    (if (zero? (% (inc epoch) 5))
        (.save_weights
          model
          (here (.format "output/{}-weights{}.h5" category (inc epoch))))))
  (print "Network trained in" (round (- (time.time) songs-read) 3) "seconds."))

(defn generate-song [category]
  (setv indices
        (with [file (open (here (.format "output/{}-indices.dat" category)) "rb")]
          (invert-dict (pickle.load file))))
  (setv uniques (len indices)
        start (time.time)
        model (doto (build-model uniques :mode "generation")
                    (.load_weights
                      (here (.format "output/{}-weights{}.h5" category epochs))))
        sequence-index [(np.random.choice (list indices))])
  (for [_ (range sequence-length)]
    (setv batch (np.zeros (, 1 1)))
    (setv (get batch (, 0 0)) (get sequence-index -1))
    (setv sample (np.random.choice
                   (range uniques)
                   :size 1
                   :p (.ravel (.predict_on_batch model batch))))
    (.append sequence-index (get sample 0)))
  (print "Generated a(n)" category "in" (round (- (time.time) start) 3) "seconds.")
  (make-dummy-song
    (lfor index sequence-index
          (get indices index))
    category))
