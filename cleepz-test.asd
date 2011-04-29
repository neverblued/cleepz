;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(defpackage #:cleepz-system
  (:use #:common-lisp #:asdf))

(in-package #:cleepz-system)

(defsystem "cleepz-test"
  :description "Template framework test"
  :version "0.1"
  :author "Demetrius Conde <condemetrius@gmail.com>"
  :depends-on (#:cleepz)
  :serial t
  :components ((:file "cleepz-test")))
