(require [hy.extra.anaphoric [ap-if]])
(import [const [song-directory here]]
        [playback [play-threaded-tune]]
        [songs [read-song]]
        [midi [make-and-save-midi]])
(import [tkinter [*]]
        [tkinter.messagebox [showerror]]
        [tkinter.filedialog [askopenfilenames asksaveasfilename]]
        [tkinter.ttk [*]]) ; Let ttk override defaults.

;;;; TkInter GUI for library management


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

(defn get-saveas-filename [title]
  (asksaveasfilename
    :initialdir (here "output")
    :title "Select path to save"
    :initialfile title
    :defaultextension ".mid"
    :filetypes (, (, "MIDI files" "*.mid"))))

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
         (play-threaded-tune (. it notes))))

(defn save-current-selection [listbox]
  (setv selection (get-selection listbox))
  (when selection
    (setv path (get-saveas-filename (. selection title)))
    (when path
      (make-and-save-midi (. selection notes) path))))

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
  (.grid (doto
           (Label window
                 :text "Chelengk"
                 :background "#C0C0C0")
           (.config :font (, "" 15)))
         :row 0 :column 0
         :padx 5 :pady 5)
  (setv infobox
        (doto (Labelframe window
                          :text "Track Info")
              (.grid :row 1 :column 3
                     :rowspan 3 :columnspan 3
                     :padx 5 :pady 5)))
  (make-label infobox "Title: " 0 0)
  (make-label infobox "Form: " 1 0)
  (make-label infobox "Composer: " 2 0)
  (make-label infobox "Makam: " 3 0)
  (make-label infobox "Usul: " 4 0)
  (setv title-label (make-label infobox " " 0 1)
        form-label (make-label infobox " " 1 1)
        composer-label (make-label infobox " " 2 1)
        makam-label (make-label infobox " " 3 1)
        usul-label (make-label infobox " " 4 1))
  (setv listbox
        (doto (Listbox window
                       :selectmode SINGLE)
              (.bind "<<ListboxSelect>>"
                     (fn [event]
                       (setv this (. event widget))
                       (when (.curselection this)
                         (update-song-details
                           this
                           [makam-label form-label
                            usul-label title-label
                            composer-label]))))
              (.grid :row 1 :column 0
                     :rowspan 3 :columnspan 3
                     :pady 5 :padx 5
                     :sticky (+ N E W S))))
  (setv scrollbar
        (doto (Scrollbar listbox :orient VERTICAL)
              (.pack :side "right"
                     :fill "y")))
  (.config listbox :yscrollcommand scrollbar.set)
  (.config scrollbar :command listbox.yview)
  (doto (Button window
                :text "Load Song"
                :command
                (fn []
                  (for [file (get-song-filenames)]
                    (add-file-to-library file listbox))))
        (.grid :row 6 :column 0
               :padx 5 :pady 5))
  (doto (Button window
                :text "Play Song"
                :command
                (fn []
                  (when (.curselection listbox)
                    (play-current-selection listbox))))
        (.grid :row 6 :column 1
               :padx 5 :pady 5))
  (doto (Button window
                :text "Remove Song"
                :command
                (fn []
                  (setv selected (.curselection listbox))
                  (when selected
                    (try
                      (.pop library (.get listbox selected))
                      (finally
                        (.delete listbox selected))))))
        (.grid :row 6 :column 2
               :padx 5 :pady 5))
  (doto (Button window
                :text "Export song"
                :command
                (fn []
                  (when (.curselection listbox)
                    (save-current-selection listbox))))
        (.grid :row 6 :column 3
               :padx 5 :pady 5))
  (.mainloop window))
