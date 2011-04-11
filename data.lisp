;; (c) Demetrius Conde <condemetrius@gmail.com>
;; Допускаю использование и распространение согласно
;; LLGPL --> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

(defpackage #:view-data
  (:use #:cl))

(defmacro isset (var-name)
  `(true? (find-symbol (symbol-name ',var-name) :view-data)))

(import 'isset :view-data)

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
