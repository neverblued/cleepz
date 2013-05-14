;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

;; basic

(defmethod build-view (view)
  (format nil "[? ~a ?]" (type-of view)))

(defmethod build-view :around (view)
  (handler-case (call-next-method)
    (condition (condition)
      (build-view-failure view condition))))

(defmethod build-view-failure (view condition)
  (error "~a (via ~a)" condition view))

;; simple

(defmethod build-view ((view print-view))
  (format nil "~a" (view-source view)))

(defmethod build-view :around ((view data-view))
  (let ((*package* (find-package '#:view-data)))
    (call-next-method)))

(defmethod build-view ((view format-view))
  (format nil (view-pattern view) (view-source view)))

;; scope

(defmethod build-view :around ((view scope-view))
  (with-view-data-alist (eval `(list ,@(view-scope view)))
    (call-next-method)))

(defmethod build-view ((view include-view))
  (view/ (eval (include-view-path view))))

;; complex

(defmethod build-view :around ((view complex-view))
  (with-view-datum 'this view
    (call-next-method)))

(defmethod build-view :around ((view complex-data-view))
  (with-view-datum 'source (view-source view)
    (call-next-method)))

(defmethod build-view ((view list-view))
  (let ((pastry nil)
        (counter 0))
    (macrolet ((join-pastry ((var list) &body collector-forms)
                 `(apply #'join (reverse (dolist (,var ,list pastry) ,@collector-forms))))
               (clip-paste ()
                 `(push (parse-view-string (clip view)) pastry)))
      (join-pastry (item-value (view-source view))
        (when (zerop counter)
          (with-view-datum 'clip-purpose :header
            (clip-paste)))
        (incf counter)
        (with-view-datum (list-view-counter-symbol view) counter
          (with-view-data ('clip-purpose :item (list-view-item-symbol view) item-value)
            (clip-paste))
          (if (< counter (length (view-source view)))
              (with-view-datum 'clip-purpose :separator
                (clip-paste))
              (with-view-datum 'clip-purpose :footer
                (clip-paste))))))))

(defmethod build-view ((view switch-view))
  (with-view-datum (switch-view-mediator-symbol view) (view-source view)
    (parse-view-string (clip view))))
