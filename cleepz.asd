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
  :depends-on (#:dc-bin #:cl-ppcre)
  :serial t
  :components ((:file "cleepz-package")
               (:file "cleepz-core")
               (:file "cleepz-basic")
               (:file "cleepz-clips")
               (:file "cleepz-list")
               (:file "cleepz-menu")
               (:file "cleepz-sugar")))
