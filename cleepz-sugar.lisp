(in-package #:cleepz)

(defmacro load-template (template-class markup-pathname)
  `(make-instance ',template-class
                  :markup (string<-pathname ,markup-pathname)))
