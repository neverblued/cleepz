;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(defpackage #:cleepz-system
  (:use #:common-lisp #:asdf))

(in-package #:cleepz-system)

(defsystem "cleepz"
  :description "Template framework"
  :version "0.2"
  :author "Demetrius Conde <condemetrius@gmail.com>"
  :depends-on (#:blackjack #:cl-ppcre #:alexandria #:iterate)
  :serial t
  :components ((:file "package")
               (:file "syntax")
               (:file "model")
               (:file "data")
               (:file "make")
               (:file "build")
               (:file "parse")
               (:file "slot")
               (:file "api")))
