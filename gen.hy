(require [macros [nget s]])
(import [songs [read-songs make-dummy-song]]
        [const [init concat invert-dict here]]
        [midi [make-midi]])
(import pickle
        [sklearn.preprocessing [LabelEncoder]]
        [numpy :as np])
(import [tensorflow.keras [Sequential]]
        [tensorflow.keras.layers
         [LSTM Dense Embedding Dropout BatchNormalization TimeDistributed]]
        [tensorflow.keras.callbacks [ModelCheckpoint]]
        [tensorflow.keras.utils [to_categorical]])

;;;; Keras LSTM music generation


(setv sequence-length 64)
(setv batch-size 16)
(setv encoder (LabelEncoder))

(defn encode [arr]
  (np.apply_along_axis (fn [col] (.fit_transform encoder col)) 0 arr))
(defn decode [arr]
  (np.apply_along_axis (fn [col] (.inverse_tranform encoder col)) 0 arr))

(defn get-notes [category]
  (concat (read-songs category :notes-only True)))

(defn build-model [network-in]
  (doto (Sequential)
        (.add (LSTM
                32
                :input_shape  (, (. network-in shape [1])
                                 (. network-in shape [2]))
                :return_sequences True))
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
                  1
                  :activation "softmax")))
        (.summary)
        (.compile :loss "mae"
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
  (for [_ (range length)]
    (print (.predict model (np.reshape pattern (, (len pattern) 1 1))))
    ;; (setv pattern (np.append pattern index)
    ;;       pattern (cut pattern 1 (len pattern)))
    )
  result)

(defn train-network [category &kwonly [retrain False] [initial-epoch 0] [epochs 10]]
  (print "Training for" category)
  (if retrain
      (do
        (print "Starting from epoch" (inc initial-epoch))
        (with [f (open (here f"output/{category}-notes.dat") "rb")]
          (setv notes (pickle.load f))))
      (do
        (setv notes (get-notes category))
        (with [f (open (here f"output/{category}-notes.dat") "wb")]
          (pickle.dump notes f))))

  ;; (setv indices (encode notes)
  ;;       (, network-in network-out) (prepare-sequences indices)
  ;;       model (build-model network-in))

  (when retrain
    (.load_weights model (here (.format "output/{}-weights{:02d}.h5" category initial-epoch)) :by_name True))

  (.fit model
        network-in
        network-out
        :epochs epochs
;;        :batch_size batch-size
        :callbacks
        [(ModelCheckpoint
           (+ (here f"output/{category}-weights") "{epoch:02d}.h5")
           :monitor "loss"
           :mode "min")]))

(defn generate-song [category &kwonly [epochs 10]]
  (setv notes (with [file (open (here f"output/{category}-notes.dat") "rb")]
                (pickle.load file)))
  (setv indices (encode notes)
        (, network-in _) (prepare-sequences indices)
        model (doto (build-model network-in)
                    (.load_weights (here (.format "output/{}-weights{:02d}.h5" category epochs)))) )

  (make-dummy-song (predict-notes model network-in (sorted (set notes)) uniques)))
