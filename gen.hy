(require [macros [S]]
         [hy.extra.anaphoric [ap-if]])
(import [const [concat invert-dict output-directory here]]
        [songs [Note Song read-songs]])
(import [glob [glob]]
        [os [path makedirs]]
        [numpy :as np]
        pickle
        [random [randint]])
(import [tensorflow.keras [Sequential]]
        [tensorflow.keras.layers
         [LSTM Dense Dropout Activation BatchNormalization]]
        [tensorflow.keras.callbacks [ModelCheckpoint]]
        [tensorflow.keras.optimizers [Adam]]
        [tensorflow.keras.utils [to_categorical]])

(setv batch-size 64
      sequence-length 2)

(defn build-model [network-in vocabulary-size]
  (doto (Sequential)
        (.add (LSTM
                256
                :input_shape (, (. network-in shape [1])
                                (. network-in shape [2]))
                :return_sequences True))
        ;; (.add (LSTM
        ;;         256
        ;;         :return_sequences True))
        (.add (LSTM 256))
        ;; (.add (BatchNormalization))
        ;; (.add (Dropout 0.3))
        ;; (.add (Dense 128))
        (.add (Activation "relu"))
        ;; (.add (BatchNormalization))
        (.add (Dropout 0.3))
        (.add (Dense vocabulary-size))
        (.add (Activation "softmax"))
        (.summary)
        (.compile
          :loss "categorical_crossentropy"
          :optimizer (Adam)
          :metrics ["accuracy"])))

(defn read-notes [genre]
  (setv result [])
  (for [song (read-songs genre)]
    (.extend result (.get-notes song)))
  result)

(defn prepare-sequences [notes &kwonly [generating False]]
  (setv note-names (sorted (set notes))
        note-to-index (invert-dict (enumerate note-names))
        vocabulary-size (len (set notes)))

  (setv network-in []
        network-out [])

  (for [i (range (- (len notes) sequence-length))]
    (setv sequence-in (cut notes i (+ i sequence-length))
          sequence-out (get notes (+ i sequence-length)))
    (.append network-in (lfor note sequence-in (get note-to-index note)))
    (.append network-out (get note-to-index sequence-out)))

  (setv normal-in (/ (np.reshape network-in (, (len network-in) sequence-length 1)) (float vocabulary-size))
        network-out (to_categorical network-out))
  (if generating
      (, network-in normal-in)
      (, normal-in network-out)))

(defn train-network [genre epochs &kwonly [retrain False]]
  (if retrain
      (do
        (print f"Retraining for {genre}...")
        (with [f (open (path.join output-directory f"{genre}-notes.dat") "rb")]
          (setv notes (pickle.load f)))
        (ap-if (list (glob (path.join output-directory f"{genre}-weights.*.hd5")))
               (do
                 (setv resume-epoch (max (lfor f it (int (get (.split (path.basename f) ".") 1)))))
                 (print f"Resuming from epoch {resume-epoch}/{epochs}."))
               (raise (ValueError "No checkpoints to resume from."))))
      (do
        (print f"Training for {genre}...")
        (setv resume-epoch 0
              notes (read-notes genre))
        (unless (path.exists output-directory)
          (makedirs output-directory))
        (with [f (open (path.join output-directory f"{genre}-notes.dat") "wb")]
          (pickle.dump notes f))))

  (setv vocabulary-size (len (set notes))
        (, network-in network-out) (prepare-sequences notes :generating False)
        model (build-model network-in vocabulary-size))

  (print vocabulary-size "unique notes out of" (len notes))

  (when retrain
    (.load_weights model (path.join output-directory f"{genre}-weights.{resume-epoch}.hd5")))

  (print "Input shape:" (. network-in shape))
  (print "Output shape:" (. network-out shape))

  (.fit model
        network-in
        network-out
        :epochs epochs
        :batch_size batch-size
        :callbacks
        [(ModelCheckpoint
           (+ (here f"output/{genre}-weights.") "{epoch}.hd5")
           :monitor "loss"
           :mode "min")]))

(defn generate-song [genre]
  (print f"Generating {genre}...")
  (with [f (open (path.join output-directory f"{genre}-notes.dat") "rb")]
    (setv notes (pickle.load f)))

  (ap-if (glob (path.join output-directory f"{genre}-weights.*.hd5"))
         (do
           (setv latest-epoch (max (lfor f it (int (get (.split (path.basename f) ".") 1)))))
           (print f"Using weights from epoch {latest-epoch}."))
         (raise (ValueError "No epoch checkpoints found to generate from.")))

  (setv note-names (sorted (set notes))
        vocabulary-size (len (set notes))
        (, network-in normal-in) (prepare-sequences notes :generating True)
        model (doto (build-model normal-in vocabulary-size)
                    (.load_weights (path.join output-directory f"{genre}-weights.{latest-epoch}.hd5"))))

  (Song (predict-notes model network-in note-names vocabulary-size)
        #*(* ["fnord"] 6)))

(defn predict-notes [model network-in note-names vocabulary-size]
  (setv index-to-note (dict (enumerate note-names))
        predict-out [])
  (for [_ (range 15)]
    (setv start (np.random.randint (dec (len network-in)))
          pattern (get network-in start))
    (for [_ (range 20)]
      (setv predict-in (/ (np.reshape pattern (, 1 (len pattern) 1))
                          (float vocabulary-size))
            index (np.argmax (.predict model predict-in))
            result (get index-to-note index))
      (.append predict-out (Note result ;; (get result 0)
                                 100
                                 (* 0.1 (randint 1 5))))
      (.append pattern index)
      (setv pattern (cut pattern 1 (len pattern)))))
  predict-out)
