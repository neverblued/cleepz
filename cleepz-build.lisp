(in-package #:cleepz)

;; data

(defparameter template-data (make-hash-table))

(defun template-datum (name)
  (gethash name template-data nil))

(defun (setf template-datum) (value name)
  (setf (gethash name template-data) value))

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
    (macrolet ((join-clips ((var list) &body builder)
                 `(apply #'join (reverse (dolist (,var ,list parts) ,@builder))))
               (add-clip (&rest mode)
                 `(push (parse-string (clip view (list ,@mode))) parts)))
      (join-clips (value (view-source view))
        (incf iterator)
        (setf (template-datum (view-item-var view)) value)
        (add-clip :clip :item :iterator iterator)
        (when (< iterator length)
          (add-clip :clip :separator :iterator iterator))))))
