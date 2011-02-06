(in-package #:cleepz)

(defun make-error-view (message)
  (make-instance 'format-view :pattern "<!-- NB! ~a -->" :source message))

(defun make-simple-view (class args)
  (if (subtypep class 'simple-view)
      (apply #'make-instance class args)
      (error "~a is not a SIMPLE-VIEW." class)))

(defun make-complex-view (name class args clips)
  (declare (ignore name))
  (if (subtypep class 'complex-view)
      (alter (apply #'make-instance class args)
             (setf (view-clips altered) clips))
      (error "~a is not a COMPLEX-VIEW." class)))

(defun make-view-clip (clause markup)
  (make-instance 'clip
                 :clause (lambda ()
                           (handler-bind
                               ((warning (lambda (condition)
                                           (muffle-warning condition))))
                             (eval clause)))
                 :markup markup))