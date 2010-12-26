(in-package #:cleepz)

(defclass list-template (template-with-clips)
  ())

(defgeneric fetch-item-clip (list-template &key)
  (:documentation "Fetch an item clip according to keys."))

(defmethod fetch-item-clip ((template list-template) &key item-number)
  (fetch-clip template :item (cond ((evenp item-number) (list :predicate "even"))
                                   ((oddp item-number)  (list :predicate "odd"))
                                   (t                   nil))))

(defgeneric templates-for-items (list-template list-data)
  (:documentation "Get a list templates suitable for viewing the list-data."))

(defmethod view ((list-template list-template) &optional (data nil))
  (let* ((data-list (getf data :items))
         (items-templates (templates-for-items list-template data-list))
         (items (mapcar (lambda (item-template data-record)
                          (view item-template data-record))
                        items-templates data-list)))
    (if (plusp (length items))
        (patch-slots (template-markup list-template)
                     (append (list :items (apply #'join items)) data))
        (view (clip-template (fetch-clip list-template :empty))))))

(defmethod templates-for-items ((list-template list-template) list-data)
  (mapcar #'clip-template
          (loop for i from 1 upto (length list-data)
             collect (fetch-item-clip list-template
                                      :item-number i))))
