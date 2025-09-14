#!/usr/bin/env bb

(require '[clojure.java.io :as io]
         '[clojure.java.shell :refer [sh]]
         '[clojure.string :as str])

(defn file-exists? [path]
  (.exists (io/file path)))

(defn find-existing-files [base-path paths]
  (->> paths
       (map (fn [path] {:path path :source (str base-path "/" path)}))
       (filter (fn [{:keys [source]}] (file-exists? source)))))

(defn create-symlink [source target]
  (sh "ln" "-sf" source target))

(defn setup-symlinks [base-path current-dir paths]
  (let [existing-files (find-existing-files base-path paths)]
    (doseq [{:keys [path source]} existing-files]
      (let [target (str current-dir "/" path)]
        (create-symlink source target)
        (println "✅ Copied" path)))
    (when (seq existing-files)
      (sh "direnv" "allow")
      (println "✅ direnv allow executed"))
    existing-files))

(when (= (first *command-line-args*) "0000000000000000000000000000000000000000")
  (let [base-path (str (System/getenv "HOME") "/Programs/bridge/bridge-app-ui-main")
        current-dir (System/getProperty "user.dir")
        paths [".env" ".env.local" ".mcp.json" ".envrc"]]
    (println "Setting up symlinks from" base-path)
    (setup-symlinks base-path current-dir paths)))


(defn message
  "Takes a string representing a log line
   and returns its message with whitespace trimmed."
  [s]
  (str/trim (second (str/split s #": "))))

(defn log-level
  "Takes a string representing a log line
   and returns its level in lower-case."
  [s]
  (str/lower-case (first (str/split (last (str/split s #"\[")) #"\]"))))


(println (message "[ERROR]:      Something went wrong"))
(println (log-level "[ERROR]:      Something went wrong"))

