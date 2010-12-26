(in-package #:cleepz)

;; make view

(defun make-warning-view (message)
  (make-instance 'format-view :pattern "[ ~a ]" :source (list message)))

(defun make-simple-view (class args)
  (if (subtypep class 'simple-view)
      (apply #'make-instance class args)
      (make-warning-view (join class " is not a SIMPLE-VIEW"))))

(defun make-complex-view (class args clips)
  (if (subtypep class 'complex-view)
      (alter (apply #'make-instance class args)
             (setf (view-clips altered) clips))
      (make-warning-view (join class " is not a COMPLEX-VIEW"))))

;; make clip

(defmacro clip-match (clause)
  `(lambda (request)
     (declare (special request))
     (handler-bind ((warning (lambda (condition)
                               (declare (ignore condition))
                               (muffle-warning))))
       (eval ,clause))))

(defun make-view-clip (clause markup)
  (make-instance 'clip
                 :clause (clip-match clause)
                 :markup markup))

;; parse view parts

(defun parse-view-args (string)
  (read-from-string (join "(" string ")")))

(defun parse-view-clause (string)
  (read-from-string string nil))

(defun parse-view-clips (string)
  (hamster (do-register-groups (clause markup)
               (*clip-regex* string)
             (pick-up (make-view-clip (parse-view-clause clause) markup)))))

;; slots

(defparameter *slot-processors* nil)

(defun careful-upcase (thing)
  (typecase thing
    (string (string-upcase thing))
    (t thing)))

(defun cleepz-symbol (&rest parts)
  (intern (apply #'join (mapcar #'careful-upcase parts)) :cleepz))

(defmacro define-slot (slot &rest parts)
  (let ((processor-name* (cond ((null parts)
                                (cleepz-symbol "cut-" slot))
                               (t
                                (cleepz-symbol "patch-" slot "-view"))))
        (define-process* (gensym)))
    `(macrolet ((,define-process* (&body body)
                  `(defun ,',processor-name* (markup)
                     ,@body)))
       ,(let ((slot-regex* (cleepz-symbol "*" slot "-regex*")))
          (cond
                                        ; cut
            ((null parts)
             `(,define-process* (values (regex-cut ,slot-regex* markup))))
                                        ; view
            (t
             (with-gensyms (make-patch*)
               `(flet ((,make-patch* (match type ,@parts &rest registers)
                         (declare (ignore match registers))
                         (build-view (,(cleepz-symbol "make-" slot "-view") (cleepz-symbol type "-view")
                                       ,@(mapcar (lambda (part)
                                                   `(,(cleepz-symbol "parse-view-" part) ,part))
                                                 parts)))))
                  (,define-process* (values (regex-replace-all ,slot-regex* markup #',make-patch*
                                                               :simple-calls t))))))))
       (setf *slot-processors*
             (nconc *slot-processors*
                    (list #',processor-name*))))))

(define-slot comment)

(define-slot space)

(define-slot complex args clips)

(define-slot simple args)

;; parse

(defun parse-string (markup)
  (apply #'mutate markup *slot-processors*))

(defun parse-file (path)
  (parse-string (string<-pathname path)))
