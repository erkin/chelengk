(require [hy.extra.anaphoric [ap-if]])
(import [const [song-directory]]
        [playback [play-tune]]
        [songs [read-song]])
(import [tkinter [*]]
        [tkinter.messagebox [showerror]]
        [tkinter.filedialog [askopenfilenames]]
        [tkinter.ttk [*]]) ; Let ttk override defaults.

;;;; TkInter GUI


(setv library {})

(defn make-label [frame text row column]
  (doto (Label frame
               :text text)
        (.grid :row row
               :column column
               :pady 5)))

(defn get-song-filenames []
  (askopenfilenames
    :initialdir song-directory
    :title "Select song to read"
    :multiple True
    :filetypes (, (, "SymbTr files" "*.txt"))))

(defn add-file-to-library [song-file listbox]
  (ap-if (read-song song-file)
         (do
           (setv song-name (. it filename))
           (setv (get library song-name) it)
           (.insert listbox END song-name))
         (showerror "Error"
                    (+ song-file " is not a valid SymbTr file."))))

(defn get-selection [listbox]
  (get library (.get listbox (.curselection listbox))))

(defn play-current-selection [listbox]
  (ap-if (get-selection listbox)
         (play-tune (. it notes))))

(defn update-song-details [listbox labels]
  (ap-if (get-selection listbox)
         (for [(, label info)
               ;; We don't need the first two fields (filename and notes).
               (zip labels (cut it 2))]
           (.configure label
                       ;; Make it a bit more readable.
                       :text (.title (.replace info "_" " "))))))

(defn launch-gui []
  (setv window
        (doto (Tk)
              (.title "Chelengk")
              (.resizable 0 0)
              (.configure :background "#C0C0C0")))
  (.grid (Label window
                :text "Chelengk"
                :background "#C0C0C0")
         :row 0
         :columnspan 6
         :pady 5)
  (setv info-box (doto (Labelframe window :text "Track Info")
                       (.grid :row 1 :column 3
                              :rowspan 3 :columnspan 3
                              :padx 5 :pady 5)))
  (make-label info-box "Title: " 0 0)
  (make-label info-box "Form: " 1 0)
  (make-label info-box "Composer: " 2 0)
  (make-label info-box "Makam: " 3 0)
  (make-label info-box "Usul: " 4 0)
  (setv title-label (make-label info-box " " 0 1)
        form-label (make-label info-box " " 1 1)
        composer-label (make-label info-box " " 2 1)
        makam-label (make-label info-box " " 3 1)
        usul-label (make-label info-box " " 4 1))
  (setv library-listbox
        (doto (Listbox window
                       :selectmode SINGLE)
              (.bind "<<ListboxSelect>>"
                     (fn [event]
                       (update-song-details
                         (. event widget)
                         [makam-label form-label
                          usul-label title-label
                          composer-label])))
              (.grid :row 1 :column 0
                     :rowspan 3 :columnspan 3
                     :padx 5 :pady 5)))
  (setv read-button
        (doto (Button window
                      :text "Load Song"
                      :command
                      (fn []
                        (for [file (get-song-filenames)]
                          (add-file-to-library file library-listbox))))
              (.grid :row 6 :column 0
                     :padx 5 :pady 5))
        play-button
        (doto (Button window
                      :text "Play Song"
                      :command
                      (fn []
                        (play-current-selection library-listbox)))
              (.grid :row 6 :column 1
                     :padx 5 :pady 5)))
  (.mainloop window))
