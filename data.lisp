(in-package #:cleepz)

(defpackage #:view-data
  (:use #:cl))

(defun datum-symbol (any-symbol &optional (intern t))
  (funcall (if intern #'intern #'find-symbol)
           (symbol-name any-symbol)
           (find-package :view-data)))

(defmacro with-datum (symbol value &body body)
  `(progv
       (list (datum-symbol ,symbol))
       (list ,value)
     ,@body))

(defmacro with-data ((&rest let-forms) &body body)
  (let ((let-forms (group let-forms 2)))
    `(progv
         (mapcar #'datum-symbol (list ,@(mapcar #'car let-forms)))
         (list ,@(mapcar #'cadr let-forms))
       ,@body)))
