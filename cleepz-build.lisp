(in-package #:cleepz)

;; data

(defpackage #:cleepz-data)

(defmacro datum (symbol)
  (with-gensyms (datum-symbol)
    `(let ((,datum-symbol (find-symbol (symbol-name ',symbol) 'cleepz-data)))
       (when (boundp ,datum-symbol)
         (symbol-value ,datum-symbol)))))

(defmacro with-datum ((symbol value) &body body)
  `(progv
       (list (intern (symbol-name ,symbol) 'cleepz-data))
       (list ,value)
     ,@body))

(defun requested (data-key)
  (declare (special request))
  (getf request data-key))

;; behaviour

(defgeneric build-view (view))

(defmethod build-view (view)
  (format nil "[ ~a ]" (type-of view)))

(defmethod build-view ((view data-view))
  (format nil "~a" (view-source view)))

(defmethod build-view ((view format-view))
  (apply #'format nil (view-pattern view) (view-source view)))

(defmethod build-view ((view list-view))
  (let ((parts nil)
        (length (length (view-source view)))
        (iterator 0))
    (declare (special iterator))
    (macrolet ((join-clips ((var list) &body builder)
                 `(apply #'join (reverse (dolist (,var ,list parts) ,@builder))))
               (add-clip (&rest mode)
                 `(push (parse-string (clip view (list ,@mode))) parts)))
      (join-clips (value (view-source view))
        (incf iterator)
        (with-datum ((view-item-var view) value)
          (add-clip :clip :item :iterator iterator))
        (when (< iterator length)
          (add-clip :clip :separator :iterator iterator))))))
