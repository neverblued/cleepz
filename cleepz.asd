;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(defpackage #:cleepz-system
  (:use #:common-lisp #:asdf))

(in-package #:cleepz-system)

(defsystem "cleepz"
  :version "0.3"
  :depends-on (#:blackjack)
  :serial t
  :components ((:file "package")
               (:file "syntax")
               (:file "model")
               (:file "data")
               (:file "make")
               (:file "home")
               (:file "build")
               (:file "parse")
               (:file "slot")
               (:file "api")))
