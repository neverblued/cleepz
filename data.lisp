;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

(defpackage #:view-data
  (:use #:cl))

(defmacro isset (var-name)
  `(boundp (find-symbol (symbol-name ',var-name) :view-data)))

(import 'isset :view-data)

(defun datum-symbol (any-symbol &optional (intern t))
  (funcall (if intern #'intern #'find-symbol)
           (symbol-name any-symbol)
           (find-package :view-data)))

(defmacro with-view-datum (symbol value &body body)
  `(progv
       (list (datum-symbol ,symbol))
       (list ,value)
     ,@body))

(defmacro with-view-data ((&rest let-alist) &body body)
  (let ((let-forms (group let-alist 2)))
    `(progv
         (mapcar #'datum-symbol (list ,@(mapcar #'car let-forms)))
         (list ,@(mapcar #'cadr let-forms))
       ,@body)))

(defmacro with-view-data-alist ((&rest let-alist) &rest body)
  (with-gensyms (scope)
    `(let ((,scope (group ,let-alist 2)))
       (progv
           (mapcar #'datum-symbol (mapcar #'car ,scope))
           (mapcar #'cadr ,scope)
         ,@body))))

(defvar view-docroot)

(defmacro with-view-docroot (path &body body)
  `(let ((cleepz::view-docroot ,path))
     ,@body))
