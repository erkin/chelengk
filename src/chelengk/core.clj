(ns chelengk.core
  (:require [clojure.pprint :refer [pprint]]
            [chelengk.scales :refer [get-makam]])
  (:gen-class))

(defn -main
  [& args]
  ;; Rast makam example
  (println (get-makam :rast)))
