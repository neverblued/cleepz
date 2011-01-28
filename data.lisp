(in-package #:cleepz)

(defpackage #:cleepz-data)

(defmacro datum (symbol)
  (with-gensyms (datum-symbol)
    `(let ((,datum-symbol (find-symbol ,(symbol-name symbol) 'cleepz-data)))
       (handler-case (values (symbol-value ,datum-symbol))
         (unbound-variable () nil)))))

(defmacro with-datum (symbol value &body body)
  `(progv
       (list (intern (symbol-name ,symbol) 'cleepz-data))
       (list ,value)
     ,@body))

(defmacro with-data ((&rest let-forms) &body body)
  (let ((let-forms (group let-forms 2)))
    `(progv
         (mapcar (lambda (symbol)
                   (intern (symbol-name symbol) 'cleepz-data))
                 (list ,@(mapcar #'car let-forms)))
         (list ,@(mapcar #'cadr let-forms))
       ,@body)))

(defun clip-tag (key)
  (declare (special request))
  (getf request key))
