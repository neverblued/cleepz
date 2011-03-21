;; (c) Demetrius Conde <condemetrius@gmail.com>
;; Допускаю использование и распространение согласно
;; LLGPL --> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

;; anything

(defmethod build-view (view)
  (format nil "[? ~a ?]" (type-of view)))

;; view

(defmethod build-view :around (view)
  (handler-case (call-next-method)
    (condition (condition)
      (build-view-failure view condition))))

(defmethod build-view-failure (view condition)
  (error "~a (via ~a)" condition view))

;; types

(defmethod build-view ((view include-view))
  (parse-view-file (eval (include-view-path view))))

(defmethod build-view ((view data-view))
  (format nil "~a" (view-source view)))

(defmethod build-view ((view format-view))
  (format nil (view-pattern view) (view-source view)))

(defmethod build-view :around ((view complex-view))
  (with-datum 'this view
    (call-next-method)))

(defmethod build-view :around ((view complex-data-view))
  (with-datum 'source (view-source view)
    (call-next-method)))

(defmethod build-view ((view list-view))
  (let ((pastry nil)
        (counter 0))
    (macrolet ((join-pastry ((var list) &body collector-forms)
                 `(apply #'join (reverse (dolist (,var ,list pastry) ,@collector-forms))))
               (clip-paste ()
                 `(push (parse-view-string (clip view)) pastry)))
      (join-pastry (item-value (view-source view))
        (incf counter)
        (with-datum (list-view-counter-symbol view) counter
          (with-data ('clip-purpose :item (list-view-item-symbol view) item-value)
            (clip-paste))
          (when (< counter (length (view-source view)))
            (with-datum 'clip-purpose :separator
              (clip-paste))))))))

(defmethod build-view ((view switch-view))
  (with-datum (switch-view-mediator-symbol view) (view-source view)
    (parse-view-string (clip view))))
