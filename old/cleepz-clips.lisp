(in-package #:cleepz)

(defclass template-with-clips (basic-template)
  ((clips :initform nil :accessor template-clips)))

(defgeneric add-clip (clip-mode clip-content template-with-clips))

(defmethod initialize-instance :after ((template template-with-clips) &key)
  (flet ((cut-clip (match clip-mode clip-content &rest registers)
           (declare (ignore match registers))
           (add-clip clip-mode clip-content template)
           ""))
    (setf (template-markup template)
          (regex-replace-all *clip-regex* (template-markup template) #'cut-clip :simple-calls t))))

(defun decode-clip-args (string-source)
  (let (args-plist)
    (dolist (key=value (split "&" string-source))
      (destructuring-bind (key value)
          (split-once "=" key=value)
        (setf (getf args-plist (keyword<-string key)) value)))
    args-plist))

(defgeneric clip-name (clip))

(defgeneric clip-args (clip))

(defgeneric clip-template (clip))

(defclass clip ()
  ((name     :initarg :name     :reader   clip-name)
   (args     :initarg :args     :accessor clip-args :initform nil)
   (template :initarg :template :reader   clip-template)))

(defmethod add-clip (clip-mode clip-content (template template-with-clips))
  (destructuring-bind (clip-name &optional (clip-args nil))
      (split "\\?" clip-mode :limit 2)
    (let ((clip-name (keyword<-string clip-name)))
      (push (make-instance 'clip
                           :name     clip-name
                           :args     (decode-clip-args clip-args)
                           :template (make-instance 'basic-template :markup clip-content))
            (template-clips template)))))

;(defun count-plist-similarity (pl1 pl2)
;  (apply #'+ (mapcar

(defgeneric fetch-clip (template-with-clips clip-name &optional clip-args))

(defmethod fetch-clip ((template template-with-clips) clip-name &optional clip-args)
  (first (sort (remove clip-name (template-clips template)
                       :key #'clip-name
                       :test-not #'eql)
               #'< :key (lambda (clip)
                          (if (equal clip-args (clip-args clip))
                              0
                              (length (clip-args clip)))))))
