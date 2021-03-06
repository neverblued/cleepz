;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(defpackage #:cleepz-test
  (:use #:common-lisp #:blackjack #:cleepz))

(in-package #:cleepz-test)

(defun run ()
  "Run test."
  (with-view-datum 'colors (list (list :name "red"   :rgb "#f00")
                                 (list :name "green" :rgb "#0f0")
                                 (list :name "blue"  :rgb "#00f")
                                 (list :name "skin"  :rgb "#face8D"))
    (let ((pathname (join (system-directory '#:cleepz) "/test.html")))
      (parse-view-file pathname))))

;(run)
