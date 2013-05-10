;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

(defun parse-view-string (markup)
  (if (equal markup "")
      ""
      (apply #'mutate markup *slot-processors*)))

(defun parse-view-file (path)
  (parse-view-string (pathname-content path)))
