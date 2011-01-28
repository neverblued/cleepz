(in-package #:cleepz)

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
        (counter 0))
    (macrolet ((join-clips ((var list) &body builder)
                 `(apply #'join (reverse (dolist (,var ,list parts) ,@builder))))
               (add-clip (&rest mode)
                 `(push (parse-string (clip view (list ,@mode))) parts)))
      (join-clips (value (view-source view))
        (incf counter)
        (with-data ((list-view-item-symbol view) value
                    (list-view-counter-symbol view) counter)
          (add-clip :purpose :item :counter counter))
        (when (< counter length)
          (add-clip :purpose :separator :counter counter))))))
