;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

;; view

(defgeneric build-view (view))
(defgeneric build-view-failure (view condition))

(defclass view () ())

;; simple view

(defclass simple-view (view) ())

;; print view

(defgeneric view-source (print-view))

(defclass print-view (simple-view)
  ((source :initarg :source :accessor view-source :initform nil)))

(defmethod view-source ((view print-view))
  (eval (slot-value view 'source)))

;; scope view

(defgeneric view-scope (view))

(defclass scope-view (view)
  ((scope :initarg :let :accessor view-scope :initform nil)))

;; include

(defgeneric include-view-path (include-view))

(defclass include-view (simple-view scope-view)
  ((path :initarg :path :accessor include-view-path)))

;; data view

(defclass data-view (scope-view print-view) ())

;; format view

(defgeneric view-pattern (format-view))

(defclass format-view (data-view)
  ((pattern :initarg :pattern :initform "~a" :accessor view-pattern)))

;; complex view

(defgeneric view-clips (complex-view))

(defclass complex-view (scope-view)
  ((clips :initform nil :initarg :clips :accessor view-clips)))

(defclass clip ()
  ((clip-clause :initarg :clause :reader clip-clause)
   (clip-markup :initform "" :initarg :markup :accessor clip-markup)))

(defgeneric clip (complex-view))

(defmethod clip ((view complex-view))
  (let ((clip (find-if (lambda (clip)
                         (funcall (clip-clause clip)))
                       (view-clips view))))
    (if clip (clip-markup clip) "")))

;; complex data view

(defclass complex-data-view (complex-view data-view) ())

;; list view

(defgeneric list-view-item-symbol (list-view))

(defgeneric list-view-counter-symbol (list-view))

(defclass list-view (complex-data-view)
  ((item-symbol :initform 'item :initarg :item :accessor list-view-item-symbol)
   (counter-symbol :initform 'counter :initarg :counter :accessor list-view-counter-symbol)))

;; switch view

(defgeneric switch-view-mediator-symbol (switch-view))

(defclass switch-view (complex-data-view)
  ((mediator-symbol :initform 'mediator :initarg :mediator :accessor switch-view-mediator-symbol)))
