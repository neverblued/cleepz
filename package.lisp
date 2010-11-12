(defpackage #:cleepz
  (use #:cl #:dc-bin))
  
(in-package #:cleepz)

;;; ~~~~~~
;;; Syntax
;;; ~~~~~~

(defparameter *slot-regex*
  "\\{\\{slot:([^\\}]+)\\}\\}")

(defparameter *clip-regex*
  (cl-ppcre::create-scanner '(:sequence "{{clip:"
                                        (:register (:non-greedy-repetition 0 nil :everything))
                                        "}}"
                                        (:regex "\\s*")
                                        (:register (:non-greedy-repetition 0 nil :everything))
                                        (:regex "\\s*")
                                        "{{/clip}}"
                              )
                            :single-line-mode t))

(defparameter *comment-regex*
  (cl-ppcre::create-scanner '(:sequence "{0y0}"
                              (:non-greedy-repetition 0 nil :everything)
                              "{-y-}"
                              )
                            :single-line-mode t))

(defun decode-clip-params (string-source)
  (let (params)
    (loop for token in (cl-ppcre::split "&" string-source)
       do (destructuring-bind (key value)
              (split-once "=" token)
            (setf (getf params (keyword<-string key))
                  value)))
    params))

;;; ~~~~~~~~~
;;; Templates
;;; ~~~~~~~~~

(defmacro template.load (template pathname)
  `(make-instance ',template
                  :markup (string<-pathname ,pathname)))

(defun patch-slots (markup plist)
  (flet ((value (match key &rest registers)
           (declare (ignorable match registers))
           (format nil "~a"
                   (getf plist (keyword<-string key) ""))))
    (cl-ppcre::regex-replace-all *slot-regex* markup #'value :simple-calls t)))

;; Basic

(defclass basic-template ()
  (
   (markup :initform ""
           :initarg :markup
           :accessor markup)
   ))

(defmethod initialize-instance :after ((template basic-template) &key)
  (setf (markup template)
        (cl-ppcre::regex-replace-all *comment-regex* (markup template) "")))

(defgeneric view (template &optional data))

(defmethod view ((template basic-template) &optional (data nil))
  (patch-slots (markup template) data))

;; Clips

(defclass clips-template (basic-template)
  (
   (clips :initform nil
             :accessor clips)
   ))

(defclass clip ()
  (
   (alias :initarg :alias
          :reader alias
          )
   (params :initarg :params
           :initform nil
           :accessor params
           )
   (template :initarg :template
             :reader template
             )
   ))

(defmethod initialize-instance :after ((template clips-template) &key)
  (flet ((add-clip (match id content &rest registers)
           (declare (ignore match registers))
           (destructuring-bind (alias &optional (params nil))
               (cl-ppcre::split "\\?" id :limit 2)
             (let ((alias (keyword<-string alias)))
               (push (make-instance 'clip
                                    :alias alias
                                    :params (decode-clip-params params)
                                    :template (make-instance 'basic-template
                                                             :markup content
                                                             )
                                    )
                     (clips template))))
           ""))
    (setf (markup template)
          (cl-ppcre::regex-replace-all *clip-regex* (markup template) #'add-clip :simple-calls t))))

;(defun count-plist-similarity (pl1 pl2)
;  (apply #'+ (mapcar

(defmethod clip ((template clips-template) alias &key (params nil))
  (first (sort (remove alias (clips template)
                       :key #'alias
                       :test-not #'eql)
               #'< :key (lambda (clip)
                          (if (equal params (params clip))
                              0
                              (length (params clip)))))))

;; List

(defclass list-template (clips-template)
  (
   ))

(defgeneric item-clip (list-template &key))

(defmethod item-clip ((template list-template) &key item-number)
  (clip template :item
           :params (cond
                     ((evenp item-number) (list :predicate "even"))
                     ((oddp item-number) (list :predicate "odd"))
                     (t nil)
                     )))

(defgeneric items-templates (list-template &optional list))

(defmethod items-templates ((template list-template) &optional (list nil))
  (mapcar #'template
          (loop for i from 1 upto (length list)
             collect (item-clip template
                                   :item-number i))))

(defmethod view ((template list-template) &optional (list nil))
  (let* ((items-templates (items-templates template list))
         (items (mapcar (lambda (item-template record)
                          (view item-template record))
                        items-templates list)))
    (if (plusp (length items))
        (patch-slots (markup template)
                     (list :items (apply #'join items)))
        (view (template (clip template :empty))))))

;; Menu

(defclass menu-template (list-template)
  (
   ))

(defmethod items-templates ((template menu-template) &optional (list nil))
  (mapcar #'template
          (loop for record in list
             collect (item-clip template
                                   :is-current? (and (boundp 'hunchentoot::*request*)
                                                     (string= (hunchentoot::url-decode
                                                               (hunchentoot::request-uri hunchentoot::*request*))
                                                              (getf record :url)))))))

(defmethod item-clip ((template menu-template) &key is-current?)
  (clip template :item
           :params (if is-current?
                       (list :mode "current")
                       nil)))
