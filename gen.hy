(require [macros [nget]])
(import [songs [read-songs make-note]]
        [const [init invert-dict here]]
        [playback [play-tune]])
(import [time [time sleep]]
        pickle
        random)
(import [numpy :as np]
        [tensorflow :as tf]
        [tensorflow.keras :as K]
        [tensorflow.keras.layers [LSTM Dense Activation Dropout Embedding TimeDistributed]])

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
  (print "Batch count:" (last batch-count))
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
  (doto (K.Sequential)
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
  (setv start (time)
        notes (get-notes category)
        indices (dfor (, index note) (enumerate (sorted (set notes)))
                      [note index])
        indexed-notes (np.asarray (lfor note notes (get indices note)) :dtype np.int32)
        uniques (len indices)
        songs-read (time))
  (print "Songs read and serialised in" (- songs-read start) "seconds.")

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
    (if [zero? (% (inc epoch) 10)]
        (.save_weights model (here (.format "output/{}-weights{}.h5" category (inc epoch))))))
  (print "Network trained in" (- (time) songs-read) "seconds."))

(defn generate-stuff [category]
  (setv indices (with [file (open (here (.format "output/{}-indices.dat" category)) "rb")]
                  (invert-dict (pickle.load file)))
        uniques (len indices)
        model (doto (build-model uniques :mode "generation")
                    (.load_weights (here (.format "output/{}-weights{}.h5" category epochs))))
        sequence-index [(random.choice (list indices))])
  (for [_ (range sequence-length)]
    (setv batch (np.zeros (, 1 1)))
    (setv (get batch (, 0 0)) (get sequence-index -1))
    (setv sample (np.random.choice
                   (range uniques)
                   :size 1
                   :p (.ravel (.predict_on_batch model batch))))
    (.append sequence-index (get sample 0)))
  (play-tune (map (fn [index] (make-note (get indices index) 100 0.0 0.1)) sequence-index)))
