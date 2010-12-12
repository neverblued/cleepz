(in-package #:cleepz)

(defgeneric view (template &optional data))

(defclass basic-template ()
  ((markup :initform "" :initarg :markup :accessor template-markup)))

(defgeneric cut-comments (template))

(defmethod initialize-instance :after ((template basic-template) &key)
  (cut-comments template))

(defmethod cut-comments ((template basic-template))
  (setf (template-markup template)
        (regex-replace-all *comment-regex* (template-markup template) "")))

(defun patch-slots (markup slots-plist)
  (flet ((markup-slot-value (match slot-name &rest registers)
           (declare (ignorable match registers))
           (format nil "~a" (getf slots-plist (keyword<-string slot-name) ""))))
    (regex-replace-all *slot-regex* markup #'markup-slot-value :simple-calls t)))

(defmethod view ((template basic-template) &optional (data nil))
  (patch-slots (template-markup template) data))
