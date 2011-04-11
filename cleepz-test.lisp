;; (c) Demetrius Conde <condemetrius@gmail.com>
;; Допускаю использование и распространение согласно
;; LLGPL --> http://opensource.franz.com/preamble.html

(defpackage #:cleepz-test
  (:use #:cl #:cleepz))

(in-package #:cleepz-test)

(defun run ()
  "Run test."
  (with-datum 'colors (list (list :name "red"   :rgb "#f00")
                            (list :name "green" :rgb "#0f0")
                            (list :name "blue"  :rgb "#00f")
                            (list :name "skin"  :rgb "#face8D"))
    (parse-view-file (merge-pathnames "lisp/cleepz/test.html" (user-homedir-pathname))))) ; how to make it portable?

;(run)
