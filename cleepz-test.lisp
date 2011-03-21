;; (c) Demetrius Conde <condemetrius@gmail.com>
;; Допускаю использование и распространение согласно
;; LLGPL --> http://opensource.franz.com/preamble.html

(defpackage #:cleepz-test
  (:use #:cl #:cleepz))

(in-package #:cleepz-test)

(defparameter colors
  (list (list :name "red"   :rgb "#f00")
        (list :name "green" :rgb "#0f0")
        (list :name "blue"  :rgb "#00f")
        (list :name "skin"  :rgb "#face8D")))

(defparameter template-pathname
  (merge-pathnames "lisp/cleepz/test.clt" (user-homedir-pathname))) ; how to make it portable?

(defun run ()
  "Run test."
  (with-datum 'colors colors
    (parse-view-file template-pathname)))

;(run)
