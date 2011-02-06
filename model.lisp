(in-package #:cleepz)

;; view

(defclass view ()
  ())

(defgeneric build-view (view))

(defgeneric build-view-failure (view condition))

;; simple view

(defclass simple-view (view)
  ())

;; data view

(defgeneric view-source (data-view))

(defclass data-view (simple-view)
  ((source :initarg :source :accessor view-source)))

(defmethod view-source ((view data-view))
  (eval (slot-value view 'source)))

;; format view

(defgeneric view-pattern (format-view))

(defclass format-view (data-view)
  ((pattern :initarg :pattern :initform "~a" :accessor view-pattern)))

;; complex view

(defgeneric view-clips (complex-view))

(defclass complex-view (view)
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

(defclass complex-data-view (complex-view data-view)
  ())

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
