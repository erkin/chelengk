(defproject chelengk "0.1.1"
  :description "Makam experiments"
  :url "https://github.com/erkin/chelengk"
  :license {:name "Mozilla Public License 2.0"}
  :dependencies [[org.clojure/clojure "1.10.0"]]
  :main ^:skip-aot chelengk.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
