(defpackage #:cleepz-system
  (:use
     #:common-lisp
     #:asdf
     )
  )

(in-package #:cleepz-system)

(defsystem "cleepz"
  :description "Template framework"
  :version "0.1"
  :author "Demetrius Conde <condemetrius@gmail.com>"
  :licence "Public Domain"
  :depends-on (#:dc-bin #:cl-ppcre #:alexandria)
  :serial t
  :components ((:file "cleepz-package")
               (:file "cleepz-syntax")
               (:file "cleepz-model")
               (:file "cleepz-build")
               (:file "cleepz-parse")))
