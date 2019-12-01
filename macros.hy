(defn parse-colon [sym]
  (list (map (fn [x]
               (if (empty? x)
                   None
                   (int x)))
             (.split (str sym) ":"))))

(defn parse-indexing [sym]
  (cond
    [(in ":" (str sym)) `(slice ~@(parse-colon sym))]
    [(in "..." (str sym)) 'Ellipsis]
    [True sym]))

(defmacro nget [ar &rest keys]
  `(get ~ar (, ~@(map parse-indexing keys))))
