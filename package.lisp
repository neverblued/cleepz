;; (c) Demetrius Conde <condemetrius@gmail.com>
;; Допускаю использование и распространение согласно
;; LLGPL --> http://opensource.franz.com/preamble.html

(defpackage #:cleepz
  (:use #:cl #:bj #:ppcre #:alexandria)
  (:export #:with-datum #:with-data #:parse-view-string #:parse-view-file))
