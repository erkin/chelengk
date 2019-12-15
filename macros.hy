(defn parse-indexing [sym]
  (defn parse-colon [sym]
    (list (map (fn [x]
                 (if (empty? x)
                     None
                     (int (eval (read-str x)))))
               (.split (str sym) ":"))))
  (cond
    [(in ":" (str sym)) `(slice ~@(parse-colon sym))]
    [(in "..." (str sym)) 'Ellipsis]
    [True sym]))

(defmacro np-get [ar &rest keys]
  `(get ~ar (, ~@(map parse-indexing keys))))

(deftag S [body]
  `(np-get ~@body))

(defmacro defattrs [klass-name
                    &optional [super-klasses []] [options []] [attrs []]
                    &rest body]
  `(do
     (import attr)
     (with-decorator ~(if options `(attr.s ~@options) 'attr.s)
       (defclass ~klass-name ~super-klasses
         ~(list (interleave
                  (lfor a attrs
                        (if (coll? a) (first a) a))
                  (lfor a attrs
                        `(attr.ib
                           ~@(if (coll? a)
                                 (list (rest a)) [])))))
         ~@body))))
