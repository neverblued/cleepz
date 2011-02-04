(in-package #:cleepz)

;; make view

(defun make-warning-view (message)
  (make-instance 'format-view :pattern "<!-- NB! ~a -->" :source message))

(defun make-simple-view (class args)
  (if (subtypep class 'simple-view)
      (apply #'make-instance class args)
      (make-warning-view (join class " is not a SIMPLE-VIEW."))))

(defun make-complex-view (class args clips)
  (if (subtypep class 'complex-view)
      (alter (apply #'make-instance class args)
             (setf (view-clips altered) clips))
      (make-warning-view (join class " is not a COMPLEX-VIEW."))))

;; make clip

(defun make-view-clip (clause markup)
  (make-instance 'clip
                 :clause (lambda ()
                           (handler-bind
                               ((warning (lambda (condition)
                                           (muffle-warning condition))))
                             (eval clause)))
                 :markup markup))

;; parse view part

(defun parse-view-args (args-template)
  (let ((*package* (find-package :view-data)))
    (read-from-string (join "(" args-template ")"))))

(defun parse-view-clause (clause-template)
  (let ((*package* (find-package :view-data)))
    (read-from-string clause-template nil)))

(defun parse-view-clips (clips-template)
  (let ((enclosed-views (make-hash-table :test #'equal))
        (patch-check nil))
    (labels ((make-id ()
               (symbol-name (gensym "view")))
             (make-patch (view-id)
               (join "<#~" view-id "~#>"))
             (remembered-patch (view-source &rest registers)
               (declare (ignore registers))
               (let ((view-patch (make-patch (make-id))))
                 (setf (gethash view-patch enclosed-views) view-source)
                 view-patch))
             (cut-enclosed-views (template)
               (regex-replace-all *complex-regex* template #'remembered-patch :simple-calls t))
             (put-views-back (patched-clip)
               (maphash (lambda (view-patch view-source)
                          (unless (find view-patch patch-check :test #'string=)
                            (setf (clip-markup patched-clip)
                                  (regex-replace (create-scanner view-patch :single-line-mode t)
                                                 (clip-markup patched-clip)
                                                 view-source
                                                 :simple-calls nil))
                            (push view-patch patch-check)))
                        enclosed-views)
               patched-clip))
      (let* ((pure-clips-template (cut-enclosed-views clips-template))
             (clips (hamster (do-register-groups (clause markup)
                                 (*clip-regex* pure-clips-template)
                               (pick-up (make-view-clip (parse-view-clause clause) markup))))))
        (mapcar #'put-views-back clips)))))

;; slots

(defparameter *slot-processors* nil)

(defun cleepz-symbol (&rest parts)
  (intern (string-upcase (apply #'join parts)) :cleepz))

(defmacro define-slot (slot &rest parts)
  (let* ((define-markup-processor* (gensym))
         (processor-name* (apply #'cleepz-symbol (if parts
                                                     `("patch-" ,slot "-view")
                                                     `("cut-" ,slot))))
         (slot-regex* (cleepz-symbol "*" slot "-regex*")))
    `(macrolet ((,define-markup-processor* (&body body)
                  `(defun ,',processor-name* (markup) (values ,@body))))
       ,(if parts
                                        ; view
            (let ((patch-slot* (gensym "patch-slot"))
                  (make-view* (cleepz-symbol "make-" slot "-view"))
                  (view-parts* (mapcar (lambda (part)
                                         (list (cleepz-symbol "parse-view-" part) part))
                                       parts)))
              `(labels ((,patch-slot* (match type ,@parts &rest registers)
                          (declare (ignore match registers))
                          (build-view (handler-case (let ((view-class (cleepz-symbol type "-view")))
                                                      (unless (fboundp ',make-view*)
                                                        (error "A slot builder function ~s must have been implemented." #',make-view*))
                                                      (unless (subtypep view-class 'view)
                                                        (error "~s must inherit VIEW." view-class))
                                                      ;(print (list ,@view-parts*))
                                                      (let ((view (,make-view* view-class ,@view-parts*)))
                                                        (unless (typep view 'view)
                                                            (error "~s is not an instance of VIEW." view))
                                                        view))
                                        (error (condition)
                                          (make-warning-view (format nil "Oh crap, ~a" condition)))))))
                 (,define-markup-processor* (regex-replace-all ,slot-regex* markup #',patch-slot* :simple-calls t))))
                                        ; cut
            `(,define-markup-processor* (regex-cut ,slot-regex* markup)))
       (setf *slot-processors*
             (nconc *slot-processors*
                    (list #',processor-name*))))))

(defmacro empty-slots ()
  `(setf *slot-processors* nil))

;; parse

(defun parse-view-string (markup)
  (if (equal markup "")
      ""
      (apply #'mutate markup *slot-processors*)))

(defun parse-view-file (path)
  (parse-view-string (string<-pathname path)))
