;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

(defparameter view-home
  (user-homedir-pathname))

(defmacro with-view-home (this &body body)
  `(let ((view-home (view-home ,this)))
     ,@body))

(defun view/ (&rest relative-path-chunks)
  (parse-view-file (apply #'join `(,view-home ,@relative-path-chunks))))
