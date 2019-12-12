(import [songs [read-songs make-dummy-song]]
        [const [init concat invert-dict here]]
        [midi [make-midi]])
(import dill
        [numpy :as np]
        [tensorflow.keras [Sequential]]
        [tensorflow.keras.layers
         [LSTM Dense Embedding Dropout BatchNormalization]]
        [tensorflow.keras.callbacks [ModelCheckpoint]]
        [tensorflow.keras.utils [to_categorical]])

;;;; Keras LSTM music generation


(setv sequence-length 64)
(setv batch-size 16)

(defn get-notes [category]
  (setv notes [])
  (for [song (read-songs category)]
    ;; Drop the duration field and convert to an array.
    (.extend notes (map init (. song notes))))
  notes)

(defn build-model [network-in uniques &kwonly [training True]]
  (doto (Sequential)
        (.add (Embedding
                :input_dim uniques
                :output_dim 512
                :batch_input_shape (, batch-size sequence-length)))
        (.add (LSTM
                256
                :return_sequences True
                :stateful True))
        (.add (Dropout 0.2))
        (.add (LSTM
                128
                :return_sequences True
                :stateful True))
        ;; (.add (BatchNormalization))
        ;; (.add (Dropout 0.2))
        ;; (.add (Dense
        ;;         256
        ;;         :activation "relu"))
        (.add (BatchNormalization))
        (.add (Dropout 0.2))
        (.add (TimeDistributed
               (Dense
                 uniques
                 :activation "softmax")))
        (.summary)
        (.compile :loss "categorical_crossentropy"
                  :optimizer "adam"
                  :metrics ["accuracy"])))

(defn prepare-sequences [notes uniques]
  (setv note-names (sorted (set notes))
        indices (dfor (, index note) (enumerate note-names) [note index]))

  (setv network-in [] network-out [])
  (for [i (range (- (len notes) sequence-length 1))]
    (setv sequence-in (cut notes i (+ i sequence-length))
          sequence-out (get notes (+ i sequence-length)))
    (.append network-in (lfor val sequence-in (get indices val)))
    (.append network-out (get indices sequence-out)))

  (, (/ (np.reshape network-in (, (len network-in) sequence-length 1)) (float uniques))
     (to_categorical network-out)))

(defn predict-notes [model network-in note-names uniques]
  (setv indices (dict (enumerate note-names))
        pattern (get network-in (np.random.randint 0 (dec (len network-in))))
        result [])
  (for [i (range 500)]
    (setv index (np.argmax (.predict model (/ (np.reshape pattern (, 1 (len pattern) 1)) (float uniques)))))
    (.append result (get indices index))
    (setv pattern (np.append pattern index)
          pattern (cut pattern 1 (len pattern))))
  result)

(defn train-network [category &kwonly [retrain False] [initial-epoch 0] [epochs 10]]
  (print "Training for" category)
  (if retrain
      (do
        (print "Starting from epoch" (inc initial-epoch))
        (with [f (open (here f"output/{category}-notes.dat") "rb")]
          (setv notes (dill.load f))))
      (do
        (setv notes (get-notes category))
        (with [f (open (here f"output/{category}-notes.dat") "wb")]
          (dill.dump notes f))))

  (setv uniques (len (set notes)))
  (print "Unique notes:" uniques)

  (setv (, network-in network-out) (prepare-sequences notes uniques))

  (setv model (build-model network-in uniques))

  (when retrain
    (.load_weights model (here f"output/{category}-weights{initial-epoch}.h5") :by_name True))

  (.fit model
        network-in
        network-out
        :epochs epochs
        :batch_size batch-size
        :callbacks
        [(ModelCheckpoint
           (+ (here f"output/{category}-weights") "{epoch:02d}.h5")
           :monitor "loss"
           :save_best_only True
           :mode "min")]))

(defn generate-song [category &kwonly [epochs 10]]
  (setv notes (with [file (open (here f"output/{category}-notes.dat") "rb")]
                (dill.load file))
        uniques (len (set notes)))

  (setv (, network-in _) (prepare-sequences notes uniques))

  (setv model (doto (build-model network-in uniques :training False)
                    (.load_weights (here f"output/{category}-weights{epochs}.h5"))))

  (make-dummy-song (predict-notes model network-in (sorted (set notes)) uniques)))
