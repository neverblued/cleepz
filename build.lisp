;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

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
  (let ((path (awith (eval (include-view-path view))
                (if (boundp 'view-docroot)
                    (join view-docroot "/" it)
                    it))))
    (with-view-data-alist (eval `(list ,@(include-view-scope view)))
      (parse-view-file (aif (include-view-site view)
                            (let ((wsf (find-package :wsf)))
                              (if wsf
                                  (funcall (symbol-function (find-symbol "FROM-DOCROOT" wsf)) (eval it) path)
                                  (error "Need WSF package for using SITE.")))
                            path)))))

(defmethod build-view ((view data-view))
  (format nil "~a" (view-source view)))

(defmethod build-view ((view format-view))
  (format nil (view-pattern view) (view-source view)))

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
