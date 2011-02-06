(in-package #:cleepz)

(defun parse-view-string (markup)
  (if (equal markup "")
      ""
      (apply #'mutate markup *slot-processors*)))

(defun parse-view-file (path)
  (parse-view-string (string<-pathname path)))
