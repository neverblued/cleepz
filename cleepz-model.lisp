(in-package #:cleepz)

;; view

(defclass view ()
  (
   ))

;; simple view

(defclass simple-view (view)
  (
   ))

;; data view

(defclass data-view (simple-view)
  (
   (source :initarg :source
           :accessor view-source
           )
   ))

(defmethod view-source ((view data-view))
  (eval (slot-value view 'source)))

;; format view

(defclass format-view (data-view)
  (
   (pattern :initarg :pattern
            :accessor view-pattern
            )
   ))

;; complex view

(defclass complex-view (view)
  (
   (clips :initform nil
          :initarg :clips
          :accessor view-clips
          )
   ))

(defmethod options ((view complex-view))
  (view-clips view))

(defclass clip ()
  (
   (clip-clause :initarg :clause
                :reader clip-clause
                )
   (clip-markup :initform ""
                :initarg :markup
                :reader clip-markup
                )
   ))

(defgeneric clip (complex-view request))

(defmethod clip ((view complex-view) request)
  (handler-case
      (clip-markup (select view request))
    (option-not-found () "")))

(defmethod selection-predicate ((clip clip) request)
  (funcall (clip-clause clip) request))

;; list view

(defclass list-view (complex-view data-view)
  (
   (item-var :initarg :item
             :accessor view-item-var
             )
   ))
